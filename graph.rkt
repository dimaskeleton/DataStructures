#lang dssl2

# HW4: Graph

import cons
import 'hw4-lib/dictionaries.rkt'
import sbox_hash 

###
### REPRESENTATION
###

# A Vertex is a natural number.
let Vertex? = nat?

# A VertexList is either
#  - None, or
#  - cons(v, vs), where v is a Vertex and vs is a VertexList
let VertexList? = Cons.ListC[Vertex?]

# A Weight is a real number. (It’s a number, but it’s neither infinite
# nor not-a-number.)
let Weight? = AndC(num?, NotC(OrC(inf, -inf, nan)))

# An OptWeight is either
# - a Weight, or
# - None
let OptWeight? = OrC(Weight?, NoneC)

# A WEdge is WEdge(Vertex, Vertex, Weight)
struct WEdge:
    let u: Vertex?
    let v: Vertex?
    let w: Weight?

# A WEdgeList is either
#  - None, or
#  - cons(w, ws), where w is a WEdge and ws is a WEdgeList
let WEdgeList? = Cons.ListC[WEdge?]

# A weighted, undirected graph ADT.
interface WUGRAPH:

    # Returns the number of vertices in the graph. (The vertices
    # are numbered 0, 1, ..., k - 1.)
    def len(self) -> nat?

    # Sets the weight of the edge between u and v to be w. Passing a
    # real number for w updates or adds the edge to have that weight,
    # whereas providing providing None for w removes the edge if
    # present. (In other words, this operation is idempotent.)
    def set_edge(self, u: Vertex?, v: Vertex?, w: OptWeight?) -> NoneC

    # Gets the weight of the edge between u and v, or None if there
    # is no such edge.
    def get_edge(self, u: Vertex?, v: Vertex?) -> OptWeight?

    # Gets a list of all vertices adjacent to v. (The order of the
    # list is unspecified.)
    def get_adjacent(self, v: Vertex?) -> VertexList?

    # Gets a list of all edges in the graph, in an unspecified order.
    # This list only includes one direction for each edge. For
    # example, if there is an edge of weight 10 between vertices
    # 1 and 3, then exactly one of WEdge(1, 3, 10) or WEdge(3, 1, 10)
    # will be in the result list, but not both.
    def get_all_edges(self) -> WEdgeList?

class WUGraph(WUGRAPH):
    
    let _matrix: VecC[VecC[OptWeight?]] # Initializes matrix to hold weights of edges between vertices
    let _length: nat? # Initializes length to hold the number of vertices in the graph

    def __init__(self, size: nat?):
        
        # If the size is not empty... 
        if size is not None:
            self._matrix = [[None for _ in range(size)] for _ in range(size)] # ... Creates a 2D list with no values for each vertex pair
            self._length = size # Sets the number of vertices based on size
        else:
            self._matrix = [] # Initializes an empty list for the matrix when size is None
            self._length = None # Sets the length to None when no size is provided

    def len(self) -> nat?:
        return self._length # Returns the number of vertices in the graph

    def set_edge(self, start_vertex: Vertex?, end_vertex: Vertex?, edge_weight: OptWeight?) -> NoneC:
        
        # Checks if the vertex indices are within the bounds of the matrix
        if start_vertex >= self._length or end_vertex >= self._length: 
            error("Attempted to access vertex out of bounds") # Raises an error if vertices are out of bounds
            
        self._matrix[start_vertex][end_vertex] = edge_weight # Sets the weight for the edge from start to end vertex
        self._matrix[end_vertex][start_vertex] = edge_weight # Sets the same weight for the edge in the opposite direction

    def get_edge(self, from_vertex: Vertex?, to_vertex: Vertex?) -> OptWeight?:
        
        # Checks if the vertex indices are within the bounds of the matrix
        if from_vertex >= self._length or to_vertex >= self._length:
            error("Attempted to access vertex out of bounds") # Raises an error if vertices are out of bounds
            
        return self._matrix[from_vertex][to_vertex] # Returns the weight of the edge between the specified vertices

    def get_adjacent(self, vertex: Vertex?) -> VertexList?:
        let adjacent_list = None # Initializes an empty list to store adjacent vertices
        
        # Iterates over all vertices to check adjacency with the given vertex
        for neighbor_index in range(self._length):
            
            # Checks if there is an edge to the neighbor vertex
            if self._matrix[vertex][neighbor_index] is not None: 
                adjacent_list = cons(neighbor_index, adjacent_list) # Adds the neighbor to the list of adjacent vertices
                
        return adjacent_list # Returns the list of adjacent vertices

    def get_all_edges(self) -> WEdgeList?:
        let edge_collection = None # Initializes an empty list to collect all edges
        
        # Iterates over all vertex pairs
        for vertex1 in range(self._length):
            for vertex2 in range(vertex1, self._length): # Ensures each pair is only considered once
                let current_weight = self.get_edge(vertex1, vertex2) # Gets the weight of the current edge
                
                # Checks if the current edge exists
                if current_weight is not None: 
                    edge_collection = cons(WEdge(vertex1, vertex2, current_weight), edge_collection) # Adds the edge to the collection
                    
        return edge_collection # Returns the collection of all edges

        
###
### List helpers
###

# To test methods that return lists with elements in an unspecified
# order, you can use these functions for sorting. Sorting these lists
# will put their elements in a predictable order, order which you can
# use when writing down the expected result part of your tests.

# sort_vertices : ListOf[Vertex] -> ListOf[Vertex]
# Sorts a list of numbers.
def sort_vertices(lst: Cons.list?) -> Cons.list?:
    def vertex_lt?(u, v): return u < v
    return Cons.sort[Vertex?](vertex_lt?, lst)

# sort_edges : ListOf[WEdge] -> ListOf[WEdge]
# Sorts a list of weighted edges, lexicographically
# ASSUMPTION: There's no need to compare weights because
# the same edge can’t appear with different weights.
def sort_edges(lst: Cons.list?) -> Cons.list?:
    def edge_lt?(e1, e2):
        return e1.u < e2.u or (e1.u == e2.u and e1.v < e2.v)
    return Cons.sort[WEdge?](edge_lt?, lst)

###
### BUILDING GRAPHS
###
    
def example_graph() -> WUGraph?:
    let result = WUGraph(6) # Create an instance of WUGraph with 6 vertices
    result.set_edge(0,3,9) # Sets an edge between vertex 0 and vertex 3 with a weight of 9
    result.set_edge(1,1,17) # Sets a self-loop at vertex 1 with a weight of 17
    result.set_edge(1,4,24) # Sets an edge between vertex 1 and vertex 4 with a weight of 24 and so on...
    result.set_edge(3,2,6)
    result.set_edge(3,4,11)
    result.set_edge(2,5,9)
    result.set_edge(2,3,-4)
    return result # Returns the filled graph

struct CityMap:
    let adjacency_graph # Holds a graph representing city connections 
    let city_to_index # Maps from city names to their index in the graph
    let index_to_city # Reverse mapping from indices in the graph back to the city names

def my_neck_of_the_woods():
    # Defines a list of city names 
    let city_list = ["Moscow", "Serpukhov", "Podolsk", "Nakhabino", "Kuryanovo", "Maryino"]
    
    let city_index_map = HashTable(5, make_sbox_hash()) # Creates a hash table for mapping city names to indices
    let index_city_map = HashTable(5, make_sbox_hash()) # Creates a hash table for mapping indices to city names 
    let graph = WUGraph(6) # Creates an instance of WUGraph with 6 vertices 
    
    # Loops through each city in the list 
    for index in range(city_list.len()):
        city_index_map.put(city_list[index], index) # Maps each city name to its index
        index_city_map.put(index, city_list[index]) # Maps each index to its corresponding city name
    
    # Loops through the cities excluding the last one 
    for index in range(city_list.len() - 1):
        graph.set_edge(0, index + 1, 5 * (index + 1)) # Sets edges from the first city to each other city with increasing weights representing distance
        
    return CityMap(graph, city_index_map, index_city_map) # Returns a CityMap filled with the graph and mappings 

###
### DFS
###

# dfs : WUGRAPH Vertex [Vertex -> any] -> None
# Performs a depth-first search starting at `start`, applying `f`
# to each vertex once as it is discovered by the search.

def dfs(graph: WUGRAPH!, start: Vertex?, f: FunC[Vertex?, AnyC]) -> NoneC:
    
    # Defines a list to track if each vertex has been visited initializing all of them to false at first
    let visited = [False for i in range(graph.len())]
    
    # Function to perform the DFS traversal recursively 
    def traverse(vertex: Vertex?, function: FunC[Vertex?, AnyC]) -> NoneC:
        
        # Checks if the current vertex hasn't been visited 
        if not visited[vertex]:
            visited[vertex] = True # Sets the current vertex as visited, setting it to True 
            function(vertex) # Applies the function to the current vertex 
            
            # Gets all adjacent vertices of the current vertex and converts it to a list 
            for neighbor in Cons.to_vec(graph.get_adjacent(vertex)):
                traverse(neighbor, function) # Recursively calls dfs_traverse on each neighboring vertex 

    traverse(start, f) # Starts the DFS traversal from the given vertex using the function

# dfs_to_list : WUGRAPH Vertex -> ListOf[Vertex]
# Performs a depth-first search starting at `start` and returns a
# list of all reachable vertices.
#
# This function uses your `dfs` function to build a list in the
# order of the search. It will pass the test below if your dfs visits
# each reachable vertex once, regardless of the order in which it calls
# `f` on them. However, you should test it more thoroughly than that
# to make sure it is calling `f` (and thus exploring the graph) in
# a correct order.
def dfs_to_list(graph: WUGRAPH!, start: Vertex?) -> VertexList?:
    let list = None
    # Add to the front when we visit a node
    dfs(graph, start, lambda new: list = cons(new, list))
    # Reverse to the get elements in visiting order.
    return Cons.rev(list)

###
### TESTING
###

## You should test your code thoroughly. Here is one test to get you started:

test 'dfs_to_list(example_graph())':
    # Cons.from_vec is a convenience function from the `cons` library that
    # allows you to write a vector (using the nice vector syntax), and get
    # a linked list with the same elements.
    assert sort_vertices(dfs_to_list(example_graph(), 0)) \
        == Cons.from_vec([0, 1, 2, 3, 4, 5])

# Tests for WUGraph Class---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Test for intialization and checking the length
test 'initialize_and_check_length':
    let g = WUGraph(5)
    assert g.len() == 5

# Test for set_edge and get_edge method 
test 'set_and_get_edge':
    let g = WUGraph(4)
    g.set_edge(0, 1, 10)
    g.set_edge(1, 2, 20)
    g.set_edge(3, 3, 30)
    assert g.get_edge(0, 1) == 10
    assert g.get_edge(1, 2) == 20
    assert g.get_edge(3, 3) == 30
    assert g.get_edge(0, 3) == None

# Test for get_adjacent method 
test 'get_adjacent_vertices':
    let g = example_graph()
    assert sort_vertices(g.get_adjacent(1)) == Cons.from_vec([1, 4])
    assert sort_vertices(g.get_adjacent(3)) == Cons.from_vec([0, 2, 4])
    
# Test for get_all_edges method 
test 'get_all_edges':
    let g = example_graph()
    let expected_edges = Cons.from_vec([
        WEdge(0, 3, 9), 
        WEdge(1, 1, 17), 
        WEdge(1, 4, 24), 
        WEdge(2, 3, -4),
        WEdge(2, 5, 9),
        WEdge(3, 4, 11)
    ])
    assert sort_edges(g.get_all_edges()) == sort_edges(expected_edges)
    
# Test for my_neck_of_woods------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
test 'my_neck_of_woods':
    let city_map = my_neck_of_the_woods()
    let city_list = ["Moscow", "Serpukhov", "Podolsk", "Nakhabino", "Kuryanovo", "Maryino"]
    for index in range(1, city_list.len()):
        assert city_map.adjacency_graph.get_edge(0, index) == 5 * index
        
# Tests for DFS function----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        
# Test for DFS traversal order
test 'dfs_traversal_order':
    let g = WUGraph(4)
    g.set_edge(0, 1, 1)
    g.set_edge(1, 2, 1)
    g.set_edge(2, 3, 1)
    assert dfs_to_list(g, 0) == Cons.from_vec([0, 1, 2, 3])

# Test for DFS visitation
test 'dfs_visitation':
    let g = WUGraph(3)
    g.set_edge(0, 1, 1)
    g.set_edge(1, 2, 1)
    assert dfs_to_list(g, 0) == Cons.from_vec([0, 1, 2])

# Test for DFS with cycles
test 'dfs_with_cycles':
    let g = WUGraph(3)
    g.set_edge(0, 1, 1)
    g.set_edge(1, 2, 1)
    g.set_edge(2, 0, 1)
    let result = dfs_to_list(g, 0)
    assert sort_vertices(result) == sort_vertices(Cons.from_vec([0, 1, 2]))

# Test for DFS on a disconnected graph
test 'dfs_disconnected_graph':
    let g = WUGraph(5)
    g.set_edge(0, 1, 1)
    g.set_edge(2, 3, 1) 
    assert dfs_to_list(g, 0) == Cons.from_vec([0, 1])
