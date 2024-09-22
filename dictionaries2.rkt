#lang dssl2

# HW3: Dictionaries

import sbox_hash

# A signature for the dictionary ADT. The contract parameters `K` and
# `V` are the key and value types of the dictionary, respectively.
interface DICT[K, V]:
    # Returns the number of key-value pairs in the dictionary.
    def len(self) -> nat?
    # Is the given key mapped by the dictionary?
    # Notation: `key` is the name of the parameter. `K` is its contract.
    def mem?(self, key: K) -> bool?
    # Gets the value associated with the given key; calls `error` if the
    # key is not present.
    def get(self, key: K) -> V
    # Modifies the dictionary to associate the given key and value. If the
    # key already exists, its value is replaced.
    def put(self, key: K, value: V) -> NoneC
    # Modifes the dictionary by deleting the association of the given key.
    def del(self, key: K) -> NoneC
    # The following method allows dictionaries to be printed
    def __print__(self, print)

# Defines node 'n' as a struct
struct n:
    let n1 # n1 represents data 
    let n2 # n2 is a pointer 

# Defines struct 'm' to hold a key-value pair within the list
struct m:
    let key # Key of the key-value pair
    let value # Value association with the key 
        
class AssociationList[K, V] (DICT):
    let _head # pointer to the first element of the list 
    let _tail # pointer to the last element of the list 
    
    def __init__(self):
        self._head=None # Initializes head pointer to None for an empty list 
        self._tail=None # Initializes tail pointer to None for an empty list 
    
    # Updated to fix tests based on feedback
    def put(self,key,value):
        # Checks if key already exists in the list 
        if self.exists?(key):
            let x=self._head # Starts at head searching list for the key 
            
            # Traverses the list until the end is reached 
            while x is not None:
                if x.n1.key==key: # If the current node key matches input key...
                    x.n1.value=value # ... Updates the node value with the new value 
                    return # Exits while loop after updating
                x=x.n2 # Move to next node if key isn't found 
            
        # If the key doesn't exist...
        else:
            self._head=n(m(key,value),self._head) # ... Inserts a new key-value pair at the head of the list 
            # Checks if the list is empty before inserting 
            if self._tail == None:
                self._tail = self._head # Sets tail to new node since theres only 1 node in the list
        
    def get(self,key):
        let x=self._head # Starts searching at the head of the list 
        
        # Continues to check until end of list is reached 
        while x is not None:
            # Checks if current node matches search key 
            if x.n1.key==key:
                return x.n1.value # Returns the value if a match is found 
            else:
                x=x.n2 # Moves to the next node
                
        error('No key') # Raises error if the key isn't found in the list 
         
    def set_x(self,key,val):
        let x=self._head # Starts searching at the head of the list 
        
        # Iterates through the entire list
        while x is not None:
            # Checks if the key is found
            if x.n1.key==key:
                x.n1.value=val # If found, updates the value of the key to the new value
                break # Exits loop after updating 
            else:
                x=x.n2 # Moves to the next node 
                    
    def exists?(self,key):
        let x=self._head # Starts at head of list to check if key exists 
        
        # Iterates through the entire list 
        while x is not None:
            # Checks if current node matches search key 
            if x.n1.key==key:
                return True # Returns true if the key is found 
            else:
                x=x.n2 # Moves to the next node 
        return False # Returns false if the key isn't found 
                
    def del(self,key):
        let x = self._head # Starts at the head of the list to search for the key to delete 
        let prev = None # Tracks the previous node 
        
        # Iterates through the entire list 
        while x is not None:
            # Checks if the key is found...
            if x.n1.key == key:
                if prev is None: #... and is the first node,
                    self._head = x.n2 # the head is moved to the next node 
                else:
                    prev.n2 = x.n2 # else, skips the current node linking the previous to the next 
                    
                # If deleting last node... 
                if x.n2 is None: 
                    self._tail = prev # Updates the tail pointer to the previous node 
                break # Exits after deleting
                
            else: 
                prev = x # Moves prev forward 
                x = x.n2 # Moves x to the next node 
                
        # If the list is empty now, 
        if self._head is None: 
            self._tail = None # Sets the tail to none aswell 
                
    def mem?(self, key):
        let x = self._head # Starts searching at the head of the list 
        
        # Iterates through the entire list 
        while x is not None:
            
            # Checks if current node matches search key 
            if x.n1.key == key:
                return True # Returns true if the key is found
            x = x.n2 # Moves to the next node 
            
        return False # Returns false if the key isn't found in the lsit 

    def len(self):
        let count = 0 # Initializes counter to track the number of elements in the list 
        let x = self._head # Starts searching at the head of the list 
        
        # Iterates through the entire list 
        while x is not None:
            count =count +  1 # Increases counter by 1 for each node in the list 
            x = x.n2 # Moves to the next node in the list 
            
        return count # Returns total number of nodes in the list 
     
    # Given print function for AssociationList        
    def __print__(self, print):
        print("#<object:AssociationList head=%p>", self._head)


test 'yOu nEeD MorE tEsTs':
    let a = AssociationList()
    assert not a.mem?('hello')
    a.put('hello', 5)
    assert a.len() == 1
    assert a.mem?('hello')
    assert a.get('hello') == 5

class HashTable[K, V] (DICT):
    let _hash # Holds hash function to hash keys 
    let _size # Keeps track of number of key pairs in the hash table 
    let _data # Array of AssociationList objects each being a bucket in the hash table 

    def __init__(self, nbuckets: nat?, hash: FunC[AnyC, nat?]):
        self._hash = hash # Initializes hash function
        self._size = 0 # Initializes hash table size to 0 
        self._data = [ AssociationList(); nbuckets ] # Initializes an array of Associationlist objects with length nbuckets

    def len(self):
          return self._size # Returns current number of key pairs in the hash table 


    def mem?(self, key: K) -> bool?:
        # Uses hash function to determine the bucket for the key and checks if that exists in the bucket 
        return self._data[self._hash(key) % self._data.len()].exists?(key)


    def get(self, key: K) -> V:
        # Uses hash function to find the bucket for the key and returns the value associated with the key
        return self._data[self._hash(key) % self._data.len()].get(key)


    def put(self, key: K, value: V) -> NoneC:
        
        # Checks if there is a bucket in the hash table 
        if self._data.len()==0: 
            error('No Hash') # Raises an error if there aren't any buckets in the hash table 
        
        else:
            # Checks if key exists in the right bucket 
            if self._data[self._hash(key) % self._data.len()].exists?(key): 
                self._data[self._hash(key) % self._data.len()].set_x(key,value) # If the key exists the value is updated 
                
            # If the key doesn't exist...
            else:
                self._data[self._hash(key) % self._data.len()].put(key,value) # Adds the key to the correlated bucket
                self._size=self._size+1 # Increments the size counter by 1 


    def del(self, key: K) -> NoneC:
        
        # If the there aren't any buckets in the hash table
        if self._data.len()==0:
            pass # Pass and do nothing 
            
        else:
            # Checks if the key exists in the right bucket 
            if self._data[self._hash(key) % self._data.len()].exists?(key):
                self._data[self._hash(key) % self._data.len()].del(key) # Delete it from the bucket 
                self._size = self._size - 1 # Decrements the size counter by 1

    # Prints representation of the hash table function with size and data
    def __print__(self, print):
        print("#<object:HashTable  _hash=... _size=%p _data=%p>",
              self._size, self._data)
              

# first_char_hasher(String) -> Natural
# A simple and bad hash function that just returns the ASCII code
# of the first character.
# Useful for debugging because it's easily predictable.
def first_char_hasher(s: str?) -> int?:
    if s.len() == 0:
        return 0
    else:
        return int(s[0])

test 'yOu nEeD MorE tEsTs, part 2':
    let h = HashTable(10, make_sbox_hash())
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    assert h.mem?('hello')
    assert h.get('hello') == 5


def compose_phrasebook(d: DICT!) -> DICT?:
    d.put('Kolo', ['Bicycle', 'KOH-loh']) # Dictionary entry for 'Kolo' with translation for bicycle and pronounciation
    d.put('Peněženku', ['Wallet', 'PEH-neh-zhehn-koo']) # Dictionary entry for 'Peněženku' with translation for wallet and pronounciation
    d.put('Záchod', ['Toilet', 'ZAHH-khoht']) # Dictionary entry for 'Záchod' with translation for toilet and pronounciation
    d.put('Mýdlo', ['Soap', 'MOOD-loh']) # Dictionary entry for 'Mýdlo' with translation for soap and pronounciation
    d.put('Nebezpečí', ['Emergency', 'NEH-behz-peh-chee']) # Dictionary antry for 'Nebezpečí' with translation for emergency and pronounciation
    return d
    
    
# Struct to represent the combination of a word's translation and pronunciation 
struct translation:
    let word  # Translated word
    let pronunciation # Pronunciation of the word

# Phrasebook using structs: 
def compose_phrasebook_structs(d: DICT!) -> DICT?:
    d.put('Kolo', translation('Bicycle', 'KOH-loh')) # Struct entry for 'Kolo' with translation and pronunciation
    d.put('Peněženku', translation('Wallet', 'PEH-neh-zhehn-koo')) # Struct entry for 'Peněženku' with translation and pronunciation
    d.put('Záchod', translation('Toilet', 'ZAHH-khoht')) # Struct entry for 'Záchod' with translation and pronunciation
    d.put('Mýdlo', translation('Soap', 'MOOD-loh')) # Struct entry for 'Mýdlo' with translation and pronunciation
    d.put('Nebezpečí', translation('Emergency', 'NEH-behz-peh-chee')) # Struct entry for 'Nebezpečí' with translation and pronunciation
    return d
    
test "AssociationList phrasebook":
    let a = AssociationList()
    compose_phrasebook(a)
    let translation_pronunciation = a.get('Kolo')
    assert translation_pronunciation[1] == 'KOH-loh'

test "HashTable phrasebook":
    let h = HashTable(10, make_sbox_hash())
    compose_phrasebook(h)
    let translation_pronunciation = h.get('Kolo') 
    assert translation_pronunciation[1] == 'KOH-loh' 
    
    
# Additional Tests For AssociationList----------------------------------------------------------------------------------------------------------------
test 'AssociationList put and get':
    let a = AssociationList()
    a.put('strawberry', 'A fruit')
    assert a.get('strawberry') == 'A fruit'

test 'AssociationList set_x':
    let a = AssociationList()
    a.put('car', 'A vehicle')
    a.set_x('car', 'A way of transport')
    assert a.get('car') == 'A way of transport'

test 'AssociationList exists?':
    let a = AssociationList()
    a.put('book', 'A source of information')
    assert a.exists?('book')
    assert not a.exists?('pen')

test 'AssociationList del':
    let a = AssociationList()
    a.put('perennials', 'A flower')
    assert a.exists?('perennials')
    a.del('perennials')
    assert not a.exists?('perennials')

test 'AssociationList mem?':
    let a = AssociationList()
    a.put('earth', 'A planet')
    assert a.mem?('earth')
    assert not a.mem?('moon')

test 'AssociationList len':
    let a = AssociationList()
    assert a.len() == 0
    a.put('jupiter', 'A gas planet')
    assert a.len() == 1
    a.put('mars', 'A rocky planet')
    assert a.len() == 2

test 'AssociationList multiple operations':
    let a = AssociationList()
    a.put('water', 'A liquid')
    a.put('ice', 'A solid')
    a.set_x('water', 'H2O')
    assert a.get('water') == 'H2O'
    assert a.exists?('ice')
    a.del('ice')
    assert not a.exists?('ice')
    assert a.len() == 1

# Additional Tests for HashTable----------------------------------------------------------------------------------------------------------------------
test "HashTable put and get":
    let h = HashTable(10, make_sbox_hash())
    h.put('testKey', 'testValue')
    let value = h.get('testKey')
    assert value == 'testValue'

test "HashTable update with put":
    let h = HashTable(10, make_sbox_hash())
    h.put('updateKey', 'initialValue')
    h.put('updateKey', 'updatedValue')
    let value = h.get('updateKey')
    assert value == 'updatedValue'

test "HashTable mem? existing and non-existing keys":
    let h = HashTable(10, make_sbox_hash())
    h.put('existKey', 'Value')
    assert h.mem?('existKey')
    assert not h.mem?('nonExistKey')

test "HashTable del on existing key":
    let h = HashTable(10, make_sbox_hash())
    h.put('delKey', 'toDelete')
    h.del('delKey')
    assert not h.mem?('delKey')

test "HashTable len before and after operation":
    let h = HashTable(10, make_sbox_hash())
    assert h.len() == 0
    h.put('lenKey1', 'value1')
    h.put('lenKey2', 'value2')
    assert h.len() == 2
    h.del('lenKey1')
    assert h.len() == 1

test "HashTable multiple operations":
    let h = HashTable(10, make_sbox_hash())
    h.put('multiKey1', 'value1')
    h.put('multiKey2', 'value2')
    h.put('multiKey1', 'newValue1') 
    assert h.get('multiKey1') == 'newValue1'
    h.del('multiKey2')
    assert not h.mem?('multiKey2')
    assert h.len() == 1
    
# Additional tests based off feedback-----------------------------------------------------------------------------------------------------------------
test 'AssociationList put unique/duplicate keys':
    let o = AssociationList()
    o.put(5, 'five')
    assert o.len() == 1
    o.put(5, 'bees')
    assert o.get(5) == 'bees'
    assert o.len() == 1

test 'AssociationList overwrite with deletion':
    let o = AssociationList()
    o.put(5, 'five')
    o.put(5, 'bees')
    o.del(5)
    assert o.mem?(5) is False

# Additional tests based on self evaluation (structs phrasebook)--------------------------------------------------------------------------------------
test "AssociationList phrasebook structs":
    let a = AssociationList()
    compose_phrasebook_structs(a)
    let translation_pronunciation = a.get('Kolo')
    assert translation_pronunciation.pronunciation == 'KOH-loh'

test "HashTable phrasebook structs":
    let h = HashTable(10, make_sbox_hash())
    compose_phrasebook_structs(h)
    let translation_pronunciation = h.get('Kolo')
    assert translation_pronunciation.pronunciation == 'KOH-loh'
    
