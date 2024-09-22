#lang dssl2

# Please find below the Posn class as presented in today's lecture.
#
# Note that its getters (get_x, get_y) expose a Posn object's contents to the outside world.
# In general, this is a bad idea and breaks what we want from encapsulation. 
#
# Your task is to remove the getter methods, and then add one or more methods so that `distance`
# still gives you the correct behavior---while maintaining `distance`s same signature.


# Represents a position on the 2D plane
class Posn:
    let x                      # fields: initialized by
    let y                      # the constructor

    def __init__(self, x, y):  # constructor: method
        self.x = x             # with a special name
        self.y = y

    # calls CalculateDistance on other using self coordinates
    # returning the calculated distance
    def distance(self, other):  
        return other.CalculateDistance(self.x, self.y) 

    def CalculateDistance(self, otherX, otherY):
        let dx = self.x - otherX
        let dy = self.y - otherY
        return (dx * dx + dy * dy).sqrt()
        
test 'Basic Posn Distance Check':
    let p1 = Posn(0,0)
    let p2 = Posn(3,4)
    assert p2.distance(p1) == 5