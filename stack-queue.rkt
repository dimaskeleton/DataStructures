#lang dssl2

# HW2: Stacks and Queues

import ring_buffer

interface STACK[T]:
    def push(self, element: T) -> NoneC
    def pop(self) -> T
    def empty?(self) -> bool?

# Defined in the `ring_buffer` library; copied here for reference.
# Do not uncomment! or you'll get errors.
# interface QUEUE[T]:
#     def enqueue(self, element: T) -> NoneC
#     def dequeue(self) -> T
#     def empty?(self) -> bool?

# Linked-list node struct (implementation detail):
struct _cons:
    let data
    let next: OrC(_cons?, NoneC)

###
### ListStack
###
'''
Contract: implements the STACK interface using a linked list 
          has methods to push onto the stack and pop elements from the stack
          
Purpose: Provides a LIFO data structure for storing/retrieving data 
         as the last element is added, it's the first removed (like stacking plates ontop eachother) 
'''
class ListStack[T] (STACK):

    # Any fields you may need can go here.
    let head: OrC(_cons?, NoneC) # Head variable can point to first node or None if empty (tracks the start of the list) 

    # Constructs an empty ListStack.
    def __init__ (self):
        self.head = None # Initalizes head with none indicating an empty list 
    #   ^ YOUR WORK GOES HERE
    
    # Push adds an element to the top of the stack       
    def push(self, element: T) -> NoneC:
        self.head = _cons(element, self.head) # Creates a new node and makes it the new head of the stack
     
    # Pop removes and returns the element thats at the top of the stack      
    def pop(self) -> T:
        # Checks if the stack is empty before pop
        if self.empty?():
            error("trying to pop from empty stack") # Raises an error if trying to pop an empty stack
        
        let data = self.head.data # Gets the data from the head node 
        self.head = self.head.next # Moves the head pointer to the next node, removing top element 
        return data # Returns the removed element 
    
    # Returns true if the stack is empty        
    def empty?(self) -> bool?: 
        return self.head is None # Returns head pointer of None indicating an empty stack
        
    # Other methods you may need can go here.

# Given test for ListStack
test "woefully insufficient":
    let s = ListStack()
    s.push(2)
    assert s.pop() == 2

###
### ListQueue
###
'''
Contract: implements the QUEUE interface from the ring_buffer library using a linked list 
          has methods to enqueue elements into the queue and dequeue elements from the queue 
          
Purpose: Provides a FIFO data structure for storing/retrieving data as the first element is 
         added, it's the first to be removed (like a queue at a amusement park)
'''
class ListQueue[T] (QUEUE):

    # Any fields you may need can go here.
    let head: OrC(_cons?, NoneC) # Head variable points to the first node of queue or None if empty (tracks the front of queue)
    let tail: OrC(_cons?, NoneC) # Tail variable points to the last node of queue or None if empty (tracks the end of queue)

    # Constructs an empty ListQueue.
    def __init__ (self):
        self.head = None # Front of the queue, initialized with None indicating an empty queue 
        self.tail = None # End of the queue, initialized with None indicating an empty queue 
    #   ^ YOUR WORK GOES HERE

    # Other methods you may need can go here.
    
    # Adds an element to the end of the queue 
    def enqueue(self, element: T) -> NoneC:
        
        let new_node = _cons(element, None) # Creates a new node for the element to be added to 
        
        # Checks if the queue is empty 
        if self.empty?():
            # If the queue is empty, the node becomes both the head and the tail 
            self.head = new_node 
            self.tail = new_node
        
        # If the node is not empty...
        else:
            self.tail.next = new_node # Links the node to the end of the queue 
            self.tail = new_node # Tail pointer is updated to the new node  
    
    # Removes and returns the element at the front of the queue                 
    def dequeue(self) -> T: 
        # Checks if the queue is empty 
        if self.empty?():
            error("dequeue is empty from queue") # Raises an error if trying to dequeue an empty queue 
            
        let data = self.head.data # Gets the data from the head node
        self.head = self.head.next # Moves the head pointer to the next node, removing the front element 
        
        # Checks if the queue is empty after calling dequeue 
        if self.head is None: 
            self.tail = None # if the queue is empty, sets the tail pointer to none resetting it 
            
        return data # Returns the data of the removed element 
        
    # Returns true if the queue is empty    
    def empty?(self) -> bool?:
        return self.head is None # Returns head pointer of None indicating an empty queue

# Given test for ListQueue 
test "woefully insufficient, part 2":
    let q = ListQueue()
    q.enqueue(2)
    assert q.dequeue() == 2

###
### Playlists
###

struct song:
    let title: str?
    let artist: str?
    let album: str?

# Enqueue five songs of your choice to the given queue, then return the first
# song that should play.
def fill_playlist (q: QUEUE!):
#   ^ YOUR WORK GOES HERE
    # List of songs, each song has a Title, Artist, and Album
    let songs = [
        song("Storm Coming", "Gnarles Barkley", "St. Elsewhere"),
        song("The High Road", "Broken Bells", "Broken Bells"),
        song("Bebop", "Dizzy Gillespie", "For Musicians Only"),
        song("I Can’t Wait", "Nu Shooz", "Tha’s Right"),
        song("A Taste of Honey", "Herb Alpert’s Tijuana Brass", "Whipped Cream & Other Delights")]
        
    # Enqueues each song in the list to the queue, looping over each song adding it to the end of the queue 
    for s in songs:
        q.enqueue(s)
    
    # Deques and returns the first song from the queue (removing and returning it) 
    return q.dequeue()
    
    
test "ListQueue playlist":
    let q = ListQueue()
    
    let first_song = fill_playlist(q)
    
    assert first_song.title == "Storm Coming"
    assert first_song.artist == "Gnarles Barkley"
    assert first_song.album == "St. Elsewhere"

# To construct a RingBuffer: RingBuffer(capacity)
test "RingBuffer playlist":
    let q = ListQueue()
    
    q.enqueue(1)
    q.enqueue(2)
    q.enqueue(3)
    q.enqueue(4)
    q.enqueue(5)
    
    assert q.dequeue() == 1
    assert q.dequeue() == 2
    assert q.dequeue() == 3
    assert q.dequeue() == 4
    assert q.dequeue() == 5
    assert q.empty?() == True

# Tests for ListStack Class---------------------------------------------------------------
    
test "Push and Pop multiple elements":
    let stack = ListStack()
    
    stack.push(1)
    stack.push(2)
    stack.push(3)
    stack.push(4)
    stack.push(5)
    
    assert stack.pop() == 5
    assert stack.pop() == 4
    assert stack.pop() == 3
    assert stack.pop() == 2
    assert stack.pop() == 1


test "Stack is empty":
    let stack = ListStack()
    
    assert stack.empty?() == True

test "Stack isn't empty after push":
    let stack = ListStack()
    
    stack.push(1)
    assert stack.empty?() == False

test "Empty stack after push and pop":
    let stack = ListStack()
    
    stack.push(1)
    stack.pop()
    
    assert stack.empty?() == True
    
test "Pushing after popping":
    let stack = ListStack()
    
    stack.push(1)
    stack.pop()
    stack.push(2)
    
    assert stack.pop() == 2
    assert stack.empty?() == True

# Tests for ListQueue Class---------------------------------------------------------------

test "Empty queue after all elements are dequeued":
    let queue = ListQueue()
    
    queue.enqueue(1)
    queue.enqueue(2)
    
    queue.dequeue()
    queue.dequeue()
    
    assert queue.empty?() == True
    
test "Queue state after multiple operations": 
    let queue = ListQueue()
    
    queue.enqueue(1)
    queue.enqueue(2)
    
    assert queue.dequeue() == 1
    
    queue.enqueue(3)
    
    assert queue.dequeue() == 2
    assert queue.dequeue() == 3
    assert queue.empty?() == True

test "Enqueueing after dequeueing":
    let queue = ListQueue()
    
    queue.enqueue(1)
    queue.dequeue()
    queue.enqueue(2)
    queue.enqueue(3)
    
    assert queue.dequeue() == 2
    assert queue.dequeue() == 3
    assert queue.empty?() == True

