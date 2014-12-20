# unitGenericBinaryTree #

## Introduction ##

A binary tree is a data structure typically used for sorting data and for providing fast access to a particular item very quickly.  TStringList uses a binary chop method when sorted which is quite fast. However, adding items to a TStringList can be painfully slow due to the reshuffling of the list content required to keep the items in order.

A binary tree doesn't suffer from this performance issue as it consists of nodes that are sorted as a result of their position within the tree.  The biggest overhead might be allocating a new node if you are using a dynamic array for example, but for performance most trees simply use items allocated in memory and store pointers to them.

The general principle is this... if you are looking for a node, you start at the root of the tree.  You compare the current node with the value you are looking for and make a decision about what to do next based on the comparison result.  If the node data is equal then you have found your item and can stop.  If the node data in the node you are looking for is less than the current, you branch left and move to another node, greater and you branch right and move to another node before beginning the comparison again.  If you hit a nil pointer, then the item you are looking for isn't in the tree.  If you are adding, the same rules apply except when you hit a nil pointer, the node containing it becomes the parent of the new node, connected by either the left or right pointer.

An example...

                       Root
                         |
                    +--------+
                    | Data 6 |
                    | L    R |
                    +--------+
                      |    |
          +-----------+    +-----------+
          |                            |
     +--------+                   +--------+ 
     | Data 3 |                   | Data 9 |
     | L    R |                   | L    R |
     +--------+                   +--------+
       0    |                       0    0
            |
            |
       +--------+
       | Data 4 |
       | L    R |
       +--------+
         0    0

This tree is storing simple integer values.  So, for example if we want to look for the value 5, we would start at the root.  5 < 6 => We branche left. 5 > 3 => We branch right. 5 > 4 => We branch right.  We have hit a nil pointer so 5 does not exist in our tree.  If we were to add 5 to the tree, it would end up linked to the right pointer of the node containing 4.

In this simple example, it is hard to see why a binary tree may be preferable to say a sorted list.  But consider a larger scale example.  If you were to add half a million nodes to a string list, adding a new one may require you to shuffle half a million items in the list.  With a binary tree there is no such shuffling, all you have to do is find the correct parent for the node.  To do this, you would expect to make no more than *n* comparisons where 2^*n* is the number of nodes.

For example, consider half a million nodes.  The value of *n* that encompasses 500000 is 19 (2^19 = 524288).  So in a perfectly balanced tree you should be able to find any node using 19 comparisons.  A new node is created and added.  No expensive shuffling.

Of course, you can add items to an unsorted list and then sort, but what if you need to know whether the item you are adding already exists?  You have two choices... scan the entire list (unsorted) or pay the cost of shuffling the list each time you add a new node so you can get the benefit of fast searches.  Binary trees do not suffer from that problem.

The only major performance issue you have to be aware of is search depth.  In the example tree above, we have a maximum search depth of 3 as the most comparisons we may need to use is 3.  Under certain conditions it is possible to add half a million nodes to a tree and get a search depth of half a million nodes.  However, you would have to be extremely unfortunate, but a search depth of 50 may not be uncommon if half a million random items are added in a random order.

To alleviate this problem you can balance your tree.  To do this, you first traverse the tree such that all nodes are visited in order (more on traversal below).  As you traverse each node, you put it in a list.  Once that's done, a binary chop is used to process the list and reinsert the items in the tree.  This has the effect of putting all the nodes that are less than a given node on the left of it and all the nodes that are greater than it on the right.  The result is a balanced tree.

As an indication of performance, adding 500000 nodes to a tree (containing random string data), ensuring there are no duplicates takes approximately 4 seconds using two threads.  Performing the same operation using a single thread and TStringList takes about 210 seconds.  Tests performed using a dual core Athlon X2 64 running at 3GHz, Windows 7 with 8GB of RAM.

This should hopefully be a sufficient introduction to binary trees.  There is lots of information available on-line.  Besides providing a useful data structure, this unit also serves as a fairly good introduction to using generics and also, private types (used to declare an event handler, one of the parameters of which depends on the type used for the nodes).

## Usage ##

First up, thread safety.  If you intend to use this class with access from multiple threads you should ensure you use the methods that include 'safe'.  When you do this, the internal 'TMultiReadExclusiveWriteSynchronizer' locks the tree in an appropriate manner (write locked for anything that is going to change the tree such as adding new nodes or deleting them, or read locked for anything that just wants to look at the tree, searching for example).  If you are only going to use a single thread to access the tree, you can dispense with the safety.

To create a tree simply call 'create'.  For example, to create an integer based tree using the provided integer node, you would use this code:-

    var
      myIntegerTree : TGenericBinaryTree<TGenericIntegerBinaryTreeNode>;

    ....

      myIntegerTree:=TGenericBinaryTree<TGenericIntegerBinaryTreeNode>.create;

And there you have it, an instance of a binary tree that stores nodes based on integer.

Cleaning up is equally simple.  Just call 'destroy'.  Any nodes placed in the tree at the time will be cleaned up auotmatically.  The general rule is that once a node is placed in the tree, the tree will be responsible for cleaning it up.  Any nodes you create that are not placed are your responsibility.  A typical example might be a node you used as the basis for a search.

To add items to the tree, follow this example:-

    var
      myIntegerTreeNode : TGenericIntegerBinaryTreeNode;

    ....

      myIntegerTreeNode:=myIntegerTree.createNode;
      myIntegerTreeNode.data:=someIntegerValue;

      myIntegerTree.placeNode(myIntegerTreeNode);

If 'placeNode' (or 'placeNodeSafe' if using the thread safe version) returns true, the node has been successfully placed in the tree.  If it returns false, the value the node represents is already in the tree (don't forget... as the node has note been placed, you must clear it up yourself).

A variation on 'placeNode' exists called 'placeOrDropNode'.  Consider the case where you are building a word list that cross references to pages in a document.  You get a word, search the tree, if it's not there you add it (which requires another search of the tree), if it is there you add a page number to a list of pages held on the node.

This is very costly, since aside from allocating the memory for the nodes, the search is the most expensive binary tree operation.

To avoid this performance hit, 'placeOrDropNode' will first attempt to place the node in the tree (this will perform a search).  If the data does not exist in the tree, the node is placed and it's pointer is returned through the 'placedNode' parameter.  If the data already exists, the node you supplied will be dropped and the node already present in the tree will returned through 'placedNode'.  The parameter 'wasPlaced' will also be set accordingly.

    procedure placeOrDropNode(nodeToPlace:NODETYPE;var placedNode:NODETYPE;var wasPlaced:boolean);

To remove a value from the tree create a node (you must clean it up) to contain the search data and call 'deleteNode'.  If the data was found, the node containing it is removed from the tree and cleaned up and the function returns true.  If the data wasn't found, the function returns false.

    function deleteNode(aNode:NODETYPE):boolean;

To clear the entire tree simply call the 'clear' method.

And finally (for basic functionality), the all important search function 'find'.
 
    procedure find(aNode:NODETYPE;var parentNode:NODETYPE;var node:NODETYPE;var lastComparison:integer);

To use this, create a node (you must clean it up) to contain the search data and call 'find'.  The routine will return three parameters.  'node' will contain the node in the tree that contains the required search data.  If this is 'nil', the data does not exist in the tree.  If it is not nil, it is the node containing the required data.

'parentNode' refers to the node in the tree that points to 'node'.  This can be nil (in this case, 'node' represents the root of the tree).  'lastComparison' returns the result of the last comparison that took place.

## Advanced Usage ##

If you would like to save your tree and load it later, TGenericBinaryTree provides the following I/O routines.

    procedure saveToStream(aStream:TStream);
    procedure saveToFile(aFilename:string);
    procedure saveToWriter(aWriter:TWriter);

    procedure loadFromStream(aStream:TStream);
    procedure loadFromFile(aFilename:string);
    procedure loadFromReader(aReader:TReader);

These follow fairly standard naming conventions.

Before you can use these routines, your node class must implement the interface 'IGenericBinaryTreeNodeStreamer'.  If your node class doesn't implement this interface, the I/O routines will throw an exception.

When the save routines are used the tree is balanced, with the nodes being saved as they are replaced in the tree.  This is to ensure optimal performance when the tree is loaded again.

**NOTE:-** I/O routines are NOT thread safe.  You should therefore ensure all other tree activity is suspended during their use.

You can also balance the tree yourself using the 'balance' method.  You should get into the habit of calling balance after loading large numbers of items to ensure you maintain optimal performance.

If your the tree content gets corrupted (potential causes are numerous but the most likely is incorrect manual modification of the tree) it will be of no use.  But how do you check?  The tree provides an easy to use mechanism for checking the tree integrity.
  
    procedure checkIntegrity;

This routine will traverse the tree and check the node to node links to ensure they are properly formed.  If any faults are found, an exception will be raised.

If you are wanting to perform actions on the tree, outside the class, you should (if you are using multi-threaded access) make use of the locking functions.

    procedure readLock;
    procedure readUnlock;
    procedure writeLock;
    procedure writeUnlock;

## Traversing The Tree ##

When you traverse the tree, you visit every single node.  Methods like 'balance' and 'checkIntegrity' make use of traversal to go through all the nodes in the tree.

To allow you to traverse the tree, the class provides three traversal methods.

    procedure traverseCLR(aNode:NODETYPE;callback:TGenericBinaryTreeTraversalCallback;var abort:boolean);
    procedure traverseLCR(aNode:NODETYPE;callback:TGenericBinaryTreeTraversalCallback;var abort:boolean);
    procedure traverseLRC(aNode:NODETYPE;callback:TGenericBinaryTreeTraversalCallback;var abort:boolean);

With 'TGenericBinaryTreeTraversalCallback' being defined as:-

    type
      TGenericBinaryTreeTraversalCallback = procedure(node:NODETYPE;var abort:boolean) of object;

They are all recursive (if you are operating on large trees you may want encounter a stack overflow) and vary only in the order in which things occur.

- **CLR** - If aNode is not nil then issue the callback for aNode, call traverseCLR for aNode.left, call traverseCLR for aNode.right otherwise exit
- **LCR** - If aNode is not nil then call traverseLCR for aNode.left, issue the callback for aNode, call traverseLCR for aNode.right otherwise exit
- **LRC** - If aNode is not nil then call traverseLRC for aNode.left, call traverseLRC for aNode.right, issue the callback for aNode otherwise exit

The most commonly used of these is LCR which traverses the tree, in data order (i.e. if it's an integer tree, the nodes will be returned in order starting with the lowest value.  If for some reason you wish to abort the traversal, simply set 'abort' to true in the callback.

## Search States ##

The tree provides a number of *interesting* search statistics.  You can clear the search stats at any time

    //------------------------------------------------------------------------------
    // Stats properties

    // Number of nodes allocated by the tree's create routines (if the flag is set to update stats)
    property allocatedNodes:TGenericBTreeNodeCountType read fAllocatedNodes;

    // Number of nodes placed in the tree
    property placedNodes:TGenericBTreeNodeCountType read fPlacedNodes;

    // Number of nodes deleted from the tree
    property deletedNodes:TGenericBTreeNodeCountType read fDeletedNodes;

    // Number of nodes currently in the tree (placed-deleted)
    property currentNodes:TGenericBTreeNodeCountType read getCurrentNodes;

    // Number of searchs performed (includes searches during placing)
    property searches:TGenericBTreeNodeCountType read fSearches;

    // Number of nodes hit during searches
    property searchedNodes:TGenericBTreeNodeCountType read fSearchedNodes;

    // Maximum search depth of tree - As a rough ball park, the search depth should be
    // X where 2^X is the number of nodes - This is not always the case, a tree with approx. 16K nodes
    // yielded a search depth of 19 (2^15 = 32768).  But if you start getting a maxdepth of
    // 50 it could be time to balance.  This is updated when the search functions are used
    // and should not be relied upon for accurate information as the exact depth will
    // depend on many factors
    property maxDepth:TGenericBTreeNodeCountType read fMaxDepth;

    // Size of the tree
    property treeSize:TGenericBTreeNodeCountType read getTreeSize;

You can clear the search stats at any time using 'clearSearchStats', and you can dump the stats to a TStrings container using the 'toStrings' method.

## Making Your Own Node Types ##

Since the whole point of this unit is to provide a mechanism by which you can easily sort lots of items, here's a quick guide to creating a node type.

First, lets take a look at the class definition for the provided integer data node 'TGenericIntegerBinaryTreeNode'.  

    TGenericIntegerBinaryTreeNode = class(TGenericBinaryTreeNode,IGenericBinaryTreeNodeStreamer)  
    protected
      fData     : integer;

      function compare(aNode:TGenericBinaryTreeNode):integer; override;
      procedure initNode; override;
      function getDataSize:integer; override;
    public
      procedure streamNodeOut(aWriter:TWriter);
      procedure streamNodeIn(aReader:TReader);

      property data:integer read fData write fData;
    end;

The first thing you will notice is that it is descended from TGenericBinaryTreeNode.  The next thing will probably be that it implements the interface 'IGenericBinaryTreeNodeStreamer'.  You do not have to implement this interface.  If you don't want to load and save data directly from the tree, then you don't need the interface and consequently you don't need to provide 'streamNodeOut' and 'streamNodeIn'.  If you do want to load and save directly, include the interface and provide these two routines.  The tree will take care of the rest.

The only other items you must provide are 'compare', 'initNode' and 'getDataSize'.

'compare' is used to compare two nodes.  It should return 0 if the nodes are equal, -1 if the data the node holds is greater than the node passed in to the routine and +1 if the data the node holds is less than the node passed in to the routine.

    function TGenericIntegerBinaryTreeNode.compare(aNode:TGenericBinaryTreeNode):integer;
    begin
      if (fData=TGenericIntegerBinaryTreeNode(aNode).data) then
      begin
        result:=0;
      end
      else
      begin
        if (fData>TGenericIntegerBinaryTreeNode(aNode).data) then
        begin
          result:=-1;
        end
        else
        begin
          result:=+1;
        end;
      end;
    end;

'initNode' is used to initialise your portion of the node.  In the case of 'TGenericIntegerBinaryTreeNode', it simply sets our internal variable that holds our data to 0.

    procedure TGenericIntegerBinaryTreeNode.initNode;
    begin
      fData:=0;
    end;

'getDataSize' is used to get the size of any complex data structures that may be attached to the node.  You will notice that 'TGenericIntegerBinaryTreeNode' returns 0.  This is because the data store (the protected variable fData) is already accounted for as it is part of the class.  If we were to have a string list contained in the node, then only the pointer to the string list would be included.  The size of any data contained by the list would need to be calculated by this routine and returned.  You may or may not want to implement this function.  If you don't need to know the total size of the tree, simply return 0 and only the nodes themselves will be counted.

    function TGenericIntegerBinaryTreeNode.getDataSize: integer;
    begin
      result:=0;
    end;

You will notice there is no cleanup function similar to 'initNode'.  If you create complex structures in 'initVars' you should override the destructor to provide proper cleanup.

It should be noted that nodes are not limited to storing the data used for sorting them.  You can create node classes that contain anything (as an example, consider the word cross referencing application mentioned earlier - in this case the data used for searching might be the word, each node then provides a list of page numbers for the cross referencing).

## Final Notes## 
The example program was banged together quick.  It contains two binary trees... an integer one and a string one.  You must initialise the integer one before using it by clicking the 'Create' button.  If you click it's 'Cleanup' button it will be destroyed and you will need to create it again.

Whilst you may be tempted to manually modify the content of the tree, my advice is don't.  That said, if you feel you must, then you must not place new nodes into the tree using any mechanisms other than the place methods and you must not remove any nodes from the tree without using the delete method.  These routines update counters which are used when balancing or checking the tree integrity.
 
## Version History ##

    Date        Version Author                 Description
    ----------- ------- ---------------------- ----------------------------------------------------------
    20-Dec-2014 1.0      C L Warne             Original release
    ----------- ------- ---------------------- ----------------------------------------------------------
