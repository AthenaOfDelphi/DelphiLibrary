unit unitGenericBinaryTree;

(*

  Generic Binary Tree
  Copyright (C) 2014 Christina Louise Warne (aka AthenaOfDelphi)

  http://athena.outer-reaches.com

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

  This unit is part of my Delphi Library (Utilities section) available at:-
    https://github.com/AthenaOfDelphi/DelphiLibrary

*)

interface

{$DEFINE _BTREEDEBUG}

uses
  Classes, SysUtils, SyncObjs,
  {$IFDEF BTREEDEBUG}
  CodeSiteLogging,
  {$ENDIF}
  Windows;

  // To do:-
  //
  // Add some callback functions to the balancer - Before store, After Store
  // If in Before you clear the node, return nil and it will be skipped during load
  // That sort of thing... why would you do this?  So you can implement things like
  // expiry of lock nodes.  Periodical cleanup during tree maintenance
  // Also add one to the place routine.  It receives newNode and currentNode (allowing
  // you to do things like increase counters and decide if the node should actually be
  // added, and what value should be returned by the place function).  The same logic
  // could be applied to the delete routin allowing counters etc. to be decreased.
  // This could be used for counting words.

  //------------------------------------------------------------------------------
  //
  // To use this binary tree, create an instance of TGenericBinaryTree passing in the node
  // type you wish to use.  TGenericIntegerBinaryTreeNode and TGenericStringBinaryTreeNode are
  // provided as two common simple types.
  //
  // CreateNode[Safe] - Create a node for the tree.  If you wish to use this function
  //   to create nodes for searches etc. if you don't want them to be counted in the
  //   allocation stat, ensure you pass false to the routine
  // PlaceNode[Safe] - Place a node in the tree.  Once placed you are no longer
  //   responsible for freeing it.  If you don't place it or it is not placed (dupe)
  //   then you are responsible
  // DeleteNode[Safe] - Remove a node that matches the provided one from the tree
  // Balance[Safe] - Re-balance the tree.  In big tree's this can improve search
  //   performance particularly with complex comparisons
  // Clear[Safe] - Clear the tree
  // CheckIntegrity - Check the integrity of the tree (Raises EBinaryTreeExceptions if
  //   problems are found)
  // Find[Safe] - Find a node that matches the provided one
  // Traverse[CLR|LCR|LRC] - Traverse the tree and execute a callback for each node
  // [Read|Write][Un]Lock - Lock/Unlock the tree for reading/writing
  //
  //------------------------------------------------------------------------------

type
  //------------------------------------------------------------------------------

  TGenericBinaryTreeNode = class;

  // Class type definition for the tree nodes - Needed so we can do a TCollection style
  // 'createNode' routine that returns the correct node type for the tree
  TGenericBinaryTreeNodeClass = class of TGenericBinaryTreeNode;

  // Array of nodes - Definition for the balance buffer
  TGenericBinaryTreeNodeArray = array of TGenericBinaryTreeNode;

  // Exception class to allow (if required) bespoke handling of special binary tree
  // exceptions
  EGenericBinaryTreeException = class(Exception);

  // Type for type casting pointers for output by intToHex (used by stats to include tree address)
  TGenericBTreeNodePointerTypeCast = integer;

  // Type for node counters - This limits counters to 4 billion
  TGenericBTreeNodeCountType = cardinal;

  //------------------------------------------------------------------------------

  // Base node definition
  IGenericBinaryTreeNodeStreamer = Interface ['{B4E0C4C5-7E94-4202-96FA-9D4460811CB6}']
    procedure streamNodeIn(aReader:TReader);
    procedure streamNodeOut(aWriter:TWriter);
  end;

  // This definition does not contain any data, but does provide the interface to
  // be used - T

  TGenericBinaryTreeNode = class(TInterfacedObject)
  protected
    fLeft         : TGenericBinaryTreeNode;
    fRight        : TGenericBinaryTreeNode;
    fParent       : TGenericBinaryTreeNode;

    //------------------------------------------------------------------------------

    // Abstract methods - Must be overriden in node classes

    // Compare
    //   This routine is used for comparing nodes.  It should return the following values:-
    //   -1 - aNode is less than us
    //    0 - aNode equals to us
    //   +1 - aNode is greater than us
    function compare(aNode:TGenericBinaryTreeNode):integer; virtual; abstract;

    // Initialise the node
    procedure initNode; virtual; abstract;

    // Get the approximate size of the data stored by this node - For stats

    function getDataSize:integer; virtual; abstract;

    //------------------------------------------------------------------------------

    // Set right pointer to aNode - Also sets parent of aNode to point back to us
    procedure setRight(aNode:TGenericBinaryTreeNode);

    // Set left pointer to aNode - Also sets parent of aNode to point back to us
    procedure setLeft(aNode:TGenericBinaryTreeNode);

    // Set parent pointer to aNode
    procedure setParent(aNode:TGenericBinaryTreeNode);

    // Set all links in one go
    procedure setLinks(parentNode,leftNode,rightNode:TGenericBinaryTreeNode);
  public
    constructor create;

    // Read only properties for traversing the tree if you should need to
    property left:TGenericBinaryTreeNode read fLeft;
    property right:TGenericBinaryTreeNode read fRight;
    property parent:TGenericBinaryTreeNode read fParent;
    property dataSize:integer read getDataSize;
  end;

  //------------------------------------------------------------------------------

  // Binary tree class

  TGenericBinaryTree<NODETYPE:TGenericBinaryTreeNode,Constructor> = class(TObject)
  private
    // Traversal callback definition - Can be used with the traverseCLR, traverseLCR and
    // traverseLRC routines of TBinaryTree to process every node in the tree.  Setting
    // abort to true will cancel the traversal

    type
      TGenericBinaryTreeTraversalCallback = procedure(node:NODETYPE;var abort:boolean) of object;

  protected
    // Root node
    fRoot             : NODETYPE;

    // Multi-thread protection - Allows multiple reads for speedy searches
    fTreeMRXWS        : TMultiReadExclusiveWriteSynchronizer;

    // Name of this tree
    fName             : string;

    // Balance buffer - Used by balance routines and the saveToStream routines (to export a file
    // that when loaded will be balanced)
    fBalanceBuffer    : TGenericBinaryTreeNodeArray;

    // Next position in balance buffer to be filled
    fBalanceBufferIdx : TGenericBTreeNodeCountType;

    // Counter used by the clear functions to keep track of how many nodes we've cleaned up
    // during the traversal
    fClearCount       : TGenericBTreeNodeCountType;

    // Last checked node - Used by the integrity check traversal handler
    fLastCheckNode    : NODETYPE;

    fIOStream         : TStream;
    fIOWriter         : TWriter;

    //------------------------------------------------------------------------------
    // Stats variables

    fAllocatedNodes         : TGenericBTreeNodeCountType;
    fPlacedNodes            : TGenericBTreeNodeCountType;
    fDeletedNodes           : TGenericBTreeNodeCountType;
    fSearches               : TGenericBTreeNodeCountType;
    fSearchedNodes          : TGenericBTreeNodeCountType;
    fMaxDepth               : TGenericBTreeNodeCountType;
    fNodeStatsCS            : TCriticalSection;
    fSearchStatsCS          : TCriticalSection;
    fParentTree             : TGenericBinaryTree<NODETYPE>;
    fDataSize               : integer;

    // function getNodeSize:TGenericBTreeNodeCountType;
    function getTreeSize:TGenericBTreeNodeCountType;
    function getCurrentNodes:TGenericBTreeNodeCountType;
    procedure clearStats;
    procedure clearPlacementStats;
    procedure getDataSizeTraversalHandler(aNode:NODETYPE;var abort:boolean);
    procedure nodeAllocated;
    procedure nodePlaced;
    procedure nodeDeleted;
    procedure searchDone(nodes:TGenericBTreeNodeCountType);
    procedure nodeAllocatedSafe;
    procedure nodePlacedSafe;
    procedure nodeDeletedSafe;
    procedure searchDoneSafe(nodes:TGenericBTreeNodeCountType);

    //------------------------------------------------------------------------------

    procedure rex(msg:string);
    procedure rexFmt(msg:string;const data:array of const);

    // Set the root node of the tree
    procedure setRoot(aNode:NODETYPE);

    // Traversal callback used by clear to free the node
    procedure clearNode(aNode:NODETYPE;var abort:boolean); virtual;

    // Internal routine to place a node in the tree - True = OK, False = Dupe
    function doPlaceNode(aNode:NODETYPE;parentNode:NODETYPE;node:NODETYPE;comparison:integer): boolean;

    // Internal routine to perform a find - If found, node<>nil, parent node = the nodes parent,
    // lastComparison = direction we went from parent, nodecount = number of nodes hit during search (i.e. search depth)
    procedure doFind(aNode:NODETYPE;var parentNode:NODETYPE;var node:NODETYPE;var lastComparison:integer;var nodeCount:integer);

    // Internal routine to perform a delete, takes output from doFind.  True = Node deleted, False = Node not deleted
    function doDeleteNode(parentNode:NODETYPE;node:NODETYPE;comparison:integer):boolean;

    // Traversal callback used to add the node to the balance buffer
    procedure addNodeToBalanceBuffer(aNode:NODETYPE;var abort:boolean);

    // Binary chop handler for the balancing routines (adds nodes back into the tree)
    procedure doBalanceChop(minIdx,maxIdx,nodeLimit:integer);

    // Internal routine to perform a tree balancing
    procedure doBalance;

    // Internal routine to perform the placeOrDrop operation
    procedure doPlaceOrDropNode(nodeToPlace:NODETYPE;var placedNode:NODETYPE;var wasPlaced:boolean);

    // Traversal callback used to test integrity of the tree
    procedure checkNode(aNode:NODETYPE;var abort:boolean);

    // Internal routine to populate the balance buffer.  Uses tarverseLCR with callback to
    // addNodeToBalanceBuffer to get the nodes in order
    procedure populateBalanceBuffer;
  public
    // Create the tree, pass the required node class in
    constructor Create;

    procedure saveToStream(aStream:TStream);
    procedure saveToFile(aFilename:string);

    procedure saveToWriter(aWriter:TWriter);

    procedure loadFromStream(aStream:TStream);
    procedure loadFromFile(aFilename:string);

    procedure loadFromReader(aReader:TReader);

    // Destroy the tree
    destructor Destroy; override;

    // Clear the tree - Safe = thread safe version
    procedure clear;
    procedure clearSafe;

    // Tree traversal utility functions - With big trees, these can be stack intensive, particularly
    // if the tree is volatile
    //  CLR = Pre-order, LCR = In-order, LRC = Post-order
    // NOTE - abort is passed as var because this calls are recursive.  You should ensure that
    // abort is initialised to false BEFORE calling one of these routines
    procedure traverseCLR(aNode:NODETYPE;callback:TGenericBinaryTreeTraversalCallback;var abort:boolean);
    procedure traverseLCR(aNode:NODETYPE;callback:TGenericBinaryTreeTraversalCallback;var abort:boolean);
    procedure traverseLRC(aNode:NODETYPE;callback:TGenericBinaryTreeTraversalCallback;var abort:boolean);

    // Find the x most node from the current
    function findRightMost(aNode:NODETYPE):NODETYPE;
    function findLeftMost(aNode:NODETYPE):NODETYPE;

    // Balance the tree - Safe = thread safe version
    //  Note - If the tree is volatile, it should be balanced periodically to prevent increased search depths
    //  caused by deleting nodes
    procedure balance;
    procedure balanceSafe;

    // Locking functions - User interface to the internal TMultiReadExclusiveWriteSynchroniser
    // If you are doing lots of unsafe stuff (clear, balance, deletes and add) you should always
    // obtain a write lock
    procedure readLock;
    procedure readUnlock;
    procedure writeLock;
    procedure writeUnlock;

    // Utility routine to perform a basic integrity check on the tree
    // Uses traverseLCR and the checkNode function to verify sort order and parenting
    procedure checkIntegrity;

    // Find a value - Create a node (if you use the tree's create, you can elect not to have
    // this shortlived node included in the allocation stats - Send false for the parameter)
    // Populate the node with the data you are looking for and pass it into the find
    // routines via the 'aNode' parameter.  The results of the find are passed out to you
    // If parentnode = nil and node <> nil - You have hit the root node
    // If parentnode <> nil and node <> nil - You have got the node and it's parent
    // If parentnode <> nil and node = nil - The value does not exist in the tree
    procedure find(aNode:NODETYPE;var parentNode:NODETYPE;var node:NODETYPE;var lastComparison:integer);
    procedure findSafe(aNode:NODETYPE;var parentNode:NODETYPE;var node:NODETYPE;var lastComparison:integer);

    // Create a new node - If you want to include the node in the stats, omit the parameter,
    // if you don't want it included set it to false - Personally, I only include nodes in the stats
    // that are going to be added to the tree
    function createNode(includeInStats:boolean=true):NODETYPE;
    function createNodeSafe(includeInStats:boolean=true):NODETYPE;

    // Place a node in the tree - Once placed in the tree, you are no longer responsible
    // for cleanup, but if the node doesn't get place (return = false) you are still
    // responsible for it
    function placeNodeSafe(aNode:NODETYPE):boolean;
    function placeNode(aNode:NODETYPE):boolean;

    // Place the new node or drop it and return the existing node
    procedure placeOrDropNode(nodeToPlace:NODETYPE;var placedNode:NODETYPE;var wasPlaced:boolean);
    procedure placeOrDropNodeSafe(nodeToPlace:NODETYPE;var placedNode:NODETYPE;var wasPlaced:boolean);

    // Delete a specified data value (provided like the 'find' routine - by way of
    // aNode) from the tree.  True = Done, False = Not found
    function deleteNodeSafe(aNode:NODETYPE):boolean;
    function deleteNode(aNode:NODETYPE):boolean;

    //------------------------------------------------------------------------------
    // Stats

    // Clear the search stats - The search stats are the only stats you should clear
    // as things like placed and deleted are used to provide actual tree critical data
    procedure clearSearchStats;

    // Output a stats block to a TStrings item - Please note, this routine uses
    // treeSize which traverses the tree to estimate it's size based on the data returned
    // by each node - For large trees this could be a problem
    procedure toStrings(dst:TStrings);
    procedure toStringsSafe(dst:TStrings);

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

    //------------------------------------------------------------------------------
    // Tree properties

    // Root node (allows you to gain access to the tree manually)
    property root:NODETYPE read fRoot;

    // Name - Appears when stats container is dumped to a log (via toStrings)
    property name:string read fName write fName;
  end;

  //------------------------------------------------------------------------------

  // Integer data node
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

  //------------------------------------------------------------------------------

  // String data node
  TGenericStringBinaryTreeNode = class(TGenericBinaryTreeNode,IGenericBinaryTreeNodeStreamer)
  protected
    fData     : string;

    function compare(aNode:TGenericBinaryTreeNode):integer; override;
    procedure initNode; override;
    function getDataSize:integer; override;
  public
    procedure streamNodeOut(aWriter:TWriter);
    procedure streamNodeIn(aReader:TReader);

    property data:string read fData write fData;
  end;

function stringSize(var theData:string):integer;

implementation

const
  // In case it's not clear why this is done, it's because System.StrRec is in the
  // implementation section of System so it's not available for us to access.
  // A strings length is  INT_STRRECSIZE + SysUtils.byteLength(<DATA>)+sizeOf(char)

  {$IF defined(CPUX64)}
  INT_STRRECSIZE = 16;
  {$ELSE}
  INT_STRRECSIZE = 12;
  {$ENDIF}

function stringSize(var theData:string):integer;
begin
  result:=INT_STRRECSIZE+SysUtils.byteLength(theData)+sizeOf(char);
end;

//------------------------------------------------------------------------------

{ TGenericBinaryTreeNode }

constructor TGenericBinaryTreeNode.create;
begin
  inherited create;

  fLeft:=nil;
  fRight:=nil;
  fParent:=nil;

  initNode;
end;

procedure TGenericBinaryTreeNode.setLinks(parentNode,leftNode,rightNode:TGenericBinaryTreeNode);
begin
  setParent(parentNode);
  setLeft(leftNode);
  setRight(rightNode);
end;

procedure TGenericBinaryTreeNode.setLeft(aNode: TGenericBinaryTreeNode);
begin
  fLeft:=aNode;

  if (aNode<>nil) then
  begin
    aNode.setParent(self);
  end;
end;

procedure TGenericBinaryTreeNode.setParent(aNode: TGenericBinaryTreeNode);
begin
  fParent:=aNode;
end;

procedure TGenericBinaryTreeNode.setRight(aNode: TGenericBinaryTreeNode);
begin
  fRight:=aNode;

  if (aNode<>nil) then
  begin
    aNode.setParent(self);
  end;
end;

//------------------------------------------------------------------------------

{ TGenericBinaryTree }

procedure TGenericBinaryTree<NODETYPE>.saveToWriter(aWriter:TWriter);
begin
  if (Supports(NODETYPE,IGenericBinaryTreeNodeStreamer)) then
  begin
    aWriter.writeInteger(currentNodes);
    fIOWriter:=aWriter;
    try
      balance;
    finally
      fIOWriter:=nil;
    end;
  end
  else
  begin
    raise EGenericBinaryTreeException.createFmt('TGenericBinaryTree<%s> - Node does not implement streamers',[NODETYPE.className]);
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.loadFromReader(aReader:TReader);
var
  aNode       : NODETYPE;
  intf        : IGenericBinaryTreeNodeStreamer;
  nodeCount   : integer;
begin
  nodeCount:=aReader.readInteger;

  repeat
    aNode:=createNode;

    if (Supports(aNode,IGenericBinaryTreeNodeStreamer,intf)) then
    begin
      intf.streamNodeIn(aReader);
      placeNode(aNode);
    end
    else
    begin
      raise EGenericBinaryTreeException.createFmt('TGenericBinaryTree<%s> - Node does not implement streamers',[NODETYPE.className]);
    end;

    dec(nodeCount);
  until (nodeCount=0);
end;

procedure TGenericBinaryTree<NODETYPE>.saveToStream(aStream:TStream);
var
  aWriter     : TWriter;
begin
  writeLock;
  aWriter:=TWriter.create(aStream,1024);
  try
    saveToWriter(aWriter);
  finally
    try
      aWriter.free;
    except
    end;

    writeUnlock;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.saveToFile(aFilename:string);
var
  aFileStream : TFileStream;
begin
  aFileStream:=TFileStream.Create(aFilename,fmOpenWrite+fmShareExclusive);
  try
    saveToStream(aFileStream);
  finally
    try
      aFileStream.free;
    except
    end;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.loadFromStream(aStream:TStream);
var
  reader      : TReader;
begin
  writeLock;
  reader:=TReader.create(aStream,1024);
  try
    clear;
    loadFromReader(reader);
  finally
    try
      reader.free;
    except
    end;
    writeUnlock;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.loadFromFile(aFilename:string);
var
  aFileStream : TFileStream;
begin
  aFileSTream:=TFileStream.create(aFilename,fmOpenRead+fmShareDenyWrite);
  try
    loadFromStream(aFileStream);
  finally
    try
      aFileStream.free;
    except
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TGenericBinaryTree<NODETYPE>.rex(msg:string);
begin
  raise EGenericBinaryTreeException.createFmt('TGenericBinaryTree<%s> - %s',[NODETYPE.className,msg]);
end;

procedure TGenericBinaryTree<NODETYPE>.rexFmt(msg:string;const data:array of const);
begin
  rex(format(msg,data));
end;

//------------------------------------------------------------------------------

procedure TGenericBinaryTree<NODETYPE>.traverseCLR(aNode:NODETYPE;callback:TGenericBinaryTreeTraversalCallback;var abort:boolean);
begin
  if (aNode<>nil) and (abort=false) then
  begin
    if (not abort) then
    begin
      callback(TGenericBinaryTreeNode(aNode),abort);
    end;
    traverseCLR(NODETYPE(aNode.left),callback,abort);
    traverseCLR(NODETYPE(aNode.right),callback,abort);
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.traverseLCR(aNode:NODETYPE;callback:TGenericBinaryTreeTraversalCallback;var abort:boolean);
begin
  if (aNode<>nil) and (abort=false) then
  begin
    {$IFDEF BTREEDEBUG}
    CodeSite.EnterMethod('traverseLCR ('+
      intToHex(integer(aNode),8)+'-'+intToHex(integer(aNode.parent),8)+'-'+intToHex(integer(aNode.left),8)+'-'+intToHex(integer(aNode.right),8));
    {$ENDIF}

    traverseLCR(NODETYPE(aNode.left),callback,abort);
    if (not abort) then
    begin
      {$IFDEF BTREEDEBUG}
      CodeSite.sendMsg('Callback - '+intToStr(TGenericIntegerBinaryTreeNode(aNode).data));
      {$ENDIF}
      callback(TGenericBinaryTreeNode(aNode),abort);
    end;
    traverseLCR(NODETYPE(aNode.right),callback,abort);

    {$IFDEF BTREEDEBUG}
    CodeSite.ExitMethod('traverseLCR');
    {$ENDIF}
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.traverseLRC(aNode:NODETYPE;callback:TGenericBinaryTreeTraversalCallback;var abort:boolean);
begin
  if (aNode<>nil) and (abort=false) then
  begin
    traverseLRC(NODETYPE(aNode.left),callback,abort);
    traverseLRC(NODETYPE(aNode.right),callback,abort);
    if (not abort) then
    begin
      callback(TGenericBinaryTreeNode(aNode),abort);
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TGenericBinaryTree<NODETYPE>.writeLock;
begin
  fTreeMRXWS.BeginWrite;
end;

procedure TGenericBinaryTree<NODETYPE>.writeUnlock;
begin
  fTreeMRXWS.endWrite;
end;

//------------------------------------------------------------------------------

procedure TGenericBinaryTree<NODETYPE>.balance;
begin
  doBalance;
end;

procedure TGenericBinaryTree<NODETYPE>.balanceSafe;
begin
  writeLock;
  try
    doBalance;
  finally
    writeUnlock;
  end;
end;

//------------------------------------------------------------------------------

procedure TGenericBinaryTree<NODETYPE>.checkIntegrity;
var
  abort   : boolean;
begin
  fLastCheckNode:=nil;
  traverseLCR(NODETYPE(fRoot),checkNode,abort);
end;

procedure TGenericBinaryTree<NODETYPE>.checkNode(aNode: NODETYPE; var abort: boolean);
var
  parentNode : TGenericBinaryTreeNode;
begin
  parentNode:=aNode.parent;

  if (fLastCheckNode<>nil) then
  begin
    if (fLastCheckNode.compare(aNode)>=0) then
    begin
      self.rex('Inconsistent tree');
    end;

    fLastCheckNode:=NODETYPE(aNode);
  end;

  if (parentNode<>nil) then
  begin
    if (parentNode.compare(aNode)>0) then
    begin
      if (NODETYPE(parentNode.right)<>aNode) then
      begin
        self.rex('Inconsistent parent right');
      end;
    end
    else
    begin
      if (NODETYPE(parentNode.left)<>aNode) then
      begin
        self.rex('Inconsistent parent left');
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TGenericBinaryTree<NODETYPE>.clear;
var
  currentNodeCount  : TGenericBTreeNodeCountType;
  abort             : boolean;
begin
  fClearCount:=0;
  abort:=false;
  traverseLRC(NODETYPE(fRoot),clearNode,abort);
  fRoot:=nil;
  currentNodeCount:=currentNodes;
  clearStats;

  if (fClearCount<>currentNodeCount) then
  begin
    self.rex('Found lost nodes during clear');
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.clearSafe;
begin
  writeLock;
  try
    clear;
  finally
    writeUnlock;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.clearNode(aNode:NODETYPE;var abort:boolean);
begin
  {$IFDEF BTREEDEBUG}
  CodeSite.sendMsg('Clearing node '+intToHex(integer(aNode),8));
  {$ENDIF}

  try
    aNode.free;
  except
  end;

  inc(fClearCount);
end;

//------------------------------------------------------------------------------

constructor TGenericBinaryTree<NODETYPE>.Create;
begin
  inherited create;

  fRoot:=nil;
  fTreeMRXWS:=TMultiReadExclusiveWriteSynchronizer.create;

  fNodeStatsCS:=TCriticalSection.create;
  fSearchStatsCS:=TCriticalSection.create;

  clearStats;
end;

//------------------------------------------------------------------------------

function TGenericBinaryTree<NODETYPE>.createNode(includeInStats:boolean): NODETYPE;
begin
  result:=NODETYPE.create;

  if (includeInStats) then
  begin
    nodeAllocated;
  end;
end;

function TGenericBinaryTree<NODETYPE>.createNodeSafe(includeInStats:boolean):NODETYPE;
begin
  result:=NODETYPE.create;

  if (includeInStats) then
  begin
    nodeAllocatedSafe;
  end;
end;

//------------------------------------------------------------------------------

function TGenericBinaryTree<NODETYPE>.findRightMost(aNode:NODETYPE):NODETYPE;
begin
  result:=aNode;
  while (result.right<>nil) do
  begin
    result:=NODETYPE(result.right);
  end;
end;

function TGenericBinaryTree<NODETYPE>.findLeftMost(aNode:NODETYPE):NODETYPE;
begin
  result:=aNode;
  while (result.left<>nil) do
  begin
    result:=NODETYPE(result.left);
  end;
end;

//------------------------------------------------------------------------------

procedure TGenericBinaryTree<NODETYPE>.addNodeToBalanceBuffer(aNode:NODETYPE;var abort:boolean);
begin
  if (aNode=nil) then
  begin
    self.rex('Balance traversal error - Nil node');
  end;

  fBalanceBuffer[fBalanceBufferIdx]:=aNode;
  inc(fBalanceBufferIdx);
end;

procedure TGenericBinaryTree<NODETYPE>.doBalanceChop(minIdx,maxIdx,nodeLimit:integer);
var
  mid   : integer;
  done  : boolean;
  intf  : IGenericBinaryTreeNodeStreamer;
begin
  if (maxIdx>=minIdx) then
  begin
    mid:=minIdx+((maxIdx-minIdx) div 2);

    if (mid>=0) and (mid<=nodeLimit) then
    begin
      if (fBalanceBuffer[mid]<>nil) then
      begin
        done:=placeNode(NODETYPE(fBalanceBuffer[mid]));

        if (not done) then
        begin
          self.rex('Balanced failed - Could not place node');
        end;

        if (fIOWriter<>nil) then
        begin
          intf:=fBalanceBuffer[mid] as IGenericBinaryTreeNodeStreamer;
          intf.streamNodeOut(fIOWriter);
        end;

        fBalanceBuffer[mid]:=nil;
      end;

      doBalanceChop(minIdx,mid-1,nodeLimit);
      doBalanceChop(mid+1,maxIdx,nodeLimit);
    end;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.populateBalanceBuffer;
var
  abort   : boolean;
begin
  fBalanceBufferIdx:=0;
  setLength(fBalanceBuffer,currentNodes);
  abort:=false;
  traverseLCR(NODETYPE(fRoot),addNodeToBalanceBuffer,abort);
end;

procedure TGenericBinaryTree<NODETYPE>.doBalance;
var
  loop              : TGenericBTreeNodeCountType;
  currentNodeCount  : TGenericBTreeNodeCountType;
begin
  currentNodeCount:=currentNodes;
  populateBalanceBuffer;

  if (fBalanceBufferIdx<currentNodeCount) then
  begin
    self.rex('Balance traversal error - Missing nodes');
  end;

  for loop:=0 to currentNodeCount-1 do
  begin
    fBalanceBuffer[loop].setLinks(nil,nil,nil);
  end;

  clearPlacementStats;
  fRoot:=nil;

  if (fIOWriter<>nil) then
  begin
    // Save the node count
    fIOWriter.WriteInteger(currentNodeCount);
  end;

  doBalanceChop(0,currentNodeCount-1,currentNodeCount-1);

  for loop:=0 to currentNodeCount-1 do
  begin
    if (fBalanceBuffer[loop]<>nil) then
    begin
      self.rex('Balance failed');
    end;
  end;

  clearSearchStats;

  setLength(fBalanceBuffer,0);
end;

//------------------------------------------------------------------------------

function TGenericBinaryTree<NODETYPE>.doDeleteNode(parentNode:NODETYPE;node:NODETYPE;comparison:integer):boolean;
var
  dstNode : NODETYPE;
begin
  if (node=nil) then
  begin
    result:=false;
  end
  else
  begin
    result:=true;

      if (parentNode=nil) then
      begin
        // This is our root node
        fRoot:=NODETYPE(node.left);

        if (fRoot=nil) then
        begin
          fRoot:=NODETYPE(node.right);

        end
        else
        begin
          if (node.right<>nil) then
          begin
            dstNode:=findRightMost(NODETYPE(fRoot));
            dstNode.setRight(node.right);
          end;
        end;

        fRoot.setParent(nil);
      end
      else
      begin
        if (comparison=0) then
        begin
          self.rex('Equality in doDeleteNode');
        end
        else
        begin
          if (comparison>0) then
          begin
            parentNode.setRight(node.left);

            if (parentNode.right=nil) then
            begin
              parentNode.setRight(node.right);
            end
            else
            begin
              if (node.right<>nil) then
              begin
                dstNode:=findRightMost(NODETYPE(parentNode.right));
                dstNode.setRight(node.right);
              end;
            end;
          end
          else
          begin
            // We went left at the parent
            parentNode.setLeft(node.left);

            if (parentNode.left=nil) then
            begin
              parentNode.setLeft(node.right);
            end
            else
            begin
              if (node.right<>nil) then
              begin
                dstNode:=findRightMost(NODETYPE(node.left));
                dstNode.setRight(node.right);
              end;
            end;
          end;
        end;
      end;

    node.free;
  end;
end;

function TGenericBinaryTree<NODETYPE>.deleteNodeSafe(aNode:NODETYPE):boolean;
var
  parentNode      : NODETYPE;
  node            : NODETYPE;
  lastComparison  : integer;
begin
  writeLock;
  try
    findSafe(aNode,parentNode,node,lastComparison);
    result:=doDeleteNode(parentNode,node,lastComparison);
  finally
    writeUnlock;
  end;

  if (result) then
  begin
    nodeDeletedSafe;
  end;
end;

function TGenericBinaryTree<NODETYPE>.deleteNode(aNode:NODETYPE):boolean;
var
  parentNode      : NODETYPE;
  node            : NODETYPE;
  lastComparison  : integer;
begin
  find(aNode,parentNode,node,lastComparison);
  result:=doDeleteNode(parentNode,node,lastComparison);

  if (result) then
  begin
    nodeDeleted;
  end;
end;

//------------------------------------------------------------------------------

function TGenericBinaryTree<NODETYPE>.placeNode(aNode:NODETYPE):boolean;
var
  parentNode  : NODETYPE;
  node        : NODETYPE;
  comparison  : integer;
begin
  find(aNode,parentNode,node,comparison);
  result:=doPlaceNode(aNode,parentNode,node,comparison);

  if (result) then
  begin
    nodePlaced;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.placeOrDropNodeSafe(nodeToPlace:NODETYPE;var placedNode:NODETYPE;var wasPlaced:boolean);
begin
  writeLock;
  try
    doPlaceOrDropNode(nodeToPlace,placedNode,wasPlaced);
  finally
    writeUnlock;
  end;

  if (wasPlaced) then
  begin
    nodePlacedSafe;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.placeOrDropNode(nodeToPlace:NODETYPE;var placedNode:NODETYPE;var wasPlaced:boolean);
begin
  doPlaceOrDropNode(nodeToPlace,placedNode,wasPlaced);

  if (wasPlaced) then
  begin
    nodePlaced;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.doPlaceOrDropNode(nodeToPlace:NODETYPE;var placedNode:NODETYPE;var wasPlaced:boolean);
var
  parentNode  : NODETYPE;
  node        : NODETYPE;
  comparison  : integer;
begin
  find(nodeToPlace,parentNode,node,comparison);

  if (node=nil) then
  begin
    doPlaceNode(nodeToPlace,parentNode,node,comparison);

    placedNode:=nodeToPlace;
    wasPlaced:=true;
  end
  else
  begin
    placedNode:=node;

    try
      nodeToPlace.free;
    except
    end;

    wasPlaced:=false;
  end;
end;

function TGenericBinaryTree<NODETYPE>.placeNodeSafe(aNode:NODETYPE):boolean;
var
  parentNode  : NODETYPE;
  node        : NODETYPE;
  comparison  : integer;
begin
  writeLock;
  try
    findSafe(aNode,parentNode,node,comparison);

    result:=doPlaceNode(aNode,parentNode,node,comparison);
  finally
    writeUnlock;
  end;

  if (result) then
  begin
    nodePlacedSafe;
  end;
end;

function TGenericBinaryTree<NODETYPE>.doPlaceNode(aNode:NODETYPE;parentNode:NODETYPE;node:NODETYPE;comparison:integer): boolean;
begin
  // Do the business and add the node to the tree
  result:=true;

  if (parentNode=nil) then
  begin
    if (fRoot=nil) then
    begin
      fRoot:=aNode;
    end
    else
    begin
      result:=false;
    end;
  end
  else
  begin
    if (node=nil) then
    begin
      if (comparison=0) then
      begin
        self.rex('Equality with empty node during place');
      end
      else
      begin
        if (comparison<0) then
        begin
          parentNode.setLeft(aNode);
        end
        else
        begin
          parentNode.setRight(aNode);
        end;
      end;
    end
    else
    begin
      result:=false;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TGenericBinaryTree<NODETYPE>.setRoot(aNode:NODETYPE);
begin
  fRoot:=aNode;
end;

//------------------------------------------------------------------------------

procedure TGenericBinaryTree<NODETYPE>.readLock;
begin
  fTreeMRXWS.BeginRead;
end;

procedure TGenericBinaryTree<NODETYPE>.readUnlock;
begin
  fTreeMRXWS.EndRead;
end;

//------------------------------------------------------------------------------

destructor TGenericBinaryTree<NODETYPE>.destroy;
begin
  clear;

  try
    fNodeStatsCS.free;
  except
  end;

  try
    fSearchStatsCS.free;
  except
  end;

  try
    fTreeMRXWS.free;
  except
  end;

  inherited;
end;

//------------------------------------------------------------------------------

procedure TGenericBinaryTree<NODETYPE>.find(aNode:NODETYPE;var parentNode:NODETYPE;var node:NODETYPE;var lastComparison:integer);
var
  nodeCount : integer;
begin
  doFind(aNode,parentNode,node,lastComparison,nodeCount);
  searchDone(nodeCount);
end;

procedure TGenericBinaryTree<NODETYPE>.findSafe(aNode:NODETYPE;var parentNode:NODETYPE;var node:NODETYPE;var lastComparison:integer);
var
  nodeCount : integer;
begin
  readLock;
  try
    doFind(aNode,parentNode,node,lastComparison,nodeCount);
    searchDoneSafe(nodeCount);
  finally
    readUnlock;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.doFind(aNode:NODETYPE;var parentNode:NODETYPE;var node:NODETYPE;var lastComparison:integer;var nodeCount:integer);
var
  done        : boolean;
  comparison  : integer;
begin
  lastComparison:=0;

  if (fRoot=nil) then
  begin
    parentNode:=nil;
    node:=nil;
    nodeCount:=0;
  end
  else
  begin
    node:=fRoot;
    parentNode:=nil;
    done:=false;
    nodeCount:=1;

    while (not done) and (node<>nil) do
    begin
      comparison:=node.compare(aNode);

      if (comparison=0) then
      begin
        done:=true;
      end
      else
      begin
        parentNode:=node;
        lastComparison:=comparison;
        inc(nodeCount);

        if (comparison<0) then
        begin
          node:=NODETYPE(node.left);
        end
        else
        begin
          node:=NODETYPE(node.right);
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TGenericBinaryTree<NODETYPE>.clearStats;
begin
  writeLock;
  try
    fAllocatedNodes:=0;
    fPlacedNodes:=0;
    fDeletedNodes:=0;
    fSearches:=0;
    fSearchedNodes:=0;
    fMaxDepth:=0;
  finally
    writeUnlock;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.clearPlacementStats;
begin
  writeLock;
  try
    fPlacedNodes:=0;
    fDeletedNodes:=0;
  finally
    writeUnlock;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.clearSearchStats;
begin
  writeLock;
  try
    fSearches:=0;
    fSearchedNodes:=0;
    fMaxDepth:=0;
  finally
    writeUnlock;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.getDataSizeTraversalHandler(aNode:NODETYPE;var abort:boolean);
begin
  fDataSize:=fDataSize+aNode.getDataSize;
end;

function TGenericBinaryTree<NODETYPE>.getTreeSize: TGenericBTreeNodeCountType;
var
  nodeSize    : integer;
  abort       : boolean;
  treeSize    : integer;
begin
  fDataSize:=0;
  abort:=false;
  traverseCLR(fRoot,getDataSizeTraversalHandler,abort);

  nodeSize:=NODETYPE.InstanceSize;
  treeSize:=self.InstanceSize;

  result:=(getCurrentNodes*TGenericBTreeNodeCountType(nodeSize))+
    TGenericBTreeNodeCountType(treeSize)+
    TGenericBTreeNodeCountType(fDataSize);
end;

function TGenericBinaryTree<NODETYPE>.getCurrentNodes:TGenericBTreeNodeCountType;
begin
  result:=fPlacedNodes-fDeletedNodes;
end;

procedure TGenericBinaryTree<NODETYPE>.nodeAllocated;
begin
  inc(fAllocatedNodes);
end;

procedure TGenericBinaryTree<NODETYPE>.nodeAllocatedSafe;
begin
  fNodeStatsCS.enter;
  try
    nodeAllocated;
  finally
    fNodeStatsCS.leave;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.nodeDeletedSafe;
begin
  fNodeStatsCS.enter;
  try
    nodeDeleted;
  finally
    fNodeStatsCS.Leave;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.nodeDeleted;
begin
  inc(fDeletedNodes);
end;

procedure TGenericBinaryTree<NODETYPE>.nodePlacedSafe;
begin
  fNodeStatsCS.enter;
  try
    nodePlaced;
  finally
    fNodeStatsCS.leave;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.nodePlaced;
begin
  inc(fPlacedNodes);
end;

procedure TGenericBinaryTree<NODETYPE>.searchDone(nodes: TGenericBTreeNodeCountType);
begin
  inc(fSearches);
  inc(fSearchedNodes,nodes);
  if (nodes>fMaxDepth) then
  begin
    fMaxDepth:=nodes;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.searchDoneSafe(nodes: TGenericBTreeNodeCountType);
begin
  fSearchStatsCS.enter;
  try
    searchDone(nodes);
  finally
    fSearchStatsCS.leave;
  end;
end;

procedure TGenericBinaryTree<NODETYPE>.toStrings(dst:TStrings);
var
  temp : string;
begin
  temp:='TGenericBinaryTree<'+NODETYPE.className+'> ($'+intToHex(TGenericBTreeNodePointerTypeCast(self),8);
  if (fName<>'') then
  begin
    temp:=temp+' - '+fname;
  end;
  temp:=temp+')';

  dst.Add(temp);
  dst.add('Allocated nodes      : '+intToStr(fAllocatedNodes));
  dst.add('Placed nodes         : '+intToStr(fPlacedNodes));
  dst.add('Deleted nodes        : '+intToStr(fDeletedNodes));
  dst.add('Current nodes        : '+intToStr(getCurrentNodes));
  dst.add('Searchdes            : '+intToStr(fSearches));
  dst.add('Total search nodes   : '+intToStr(fSearchedNodes));
  if (fSearches>0) then
  begin
    dst.add('Average search depth : '+format('%8.3f',[fSearchedNodes/fSearches]));
  end;
  dst.add('Maximum search depth : '+intToStr(fMaxDepth));
  dst.add('Node size (Instance) : '+intToStr(NODETYPE.InstanceSize));
  dst.add('Tree size            : '+intToStr(getTreeSize));
end;

procedure TGenericBinaryTree<NODETYPE>.toStringsSafe(dst: TStrings);
begin
  writeLock;
  try
    toStrings(dst);
  finally
    writeUnlock;
  end;
end;

//------------------------------------------------------------------------------

{ TGenericIntegerBinaryTreeNode }

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

function TGenericIntegerBinaryTreeNode.getDataSize: integer;
begin
  result:=0;
end;

procedure TGenericIntegerBinaryTreeNode.initNode;
begin
  fData:=0;
end;

procedure TGenericIntegerBinaryTreeNode.streamNodeOut(aWriter:TWriter);
begin
  aWriter.WriteInteger(fData);
end;

procedure TGenericIntegerBinaryTreeNode.streamNodeIn(aReader:TReader);
begin
  fData:=aReader.ReadInteger;
end;

//------------------------------------------------------------------------------

{ TGenericStringBinaryTreeNode }

function TGenericStringBinaryTreeNode.compare(aNode: TGenericBinaryTreeNode): integer;
begin
  result:=compareText(TGenericStringBinaryTreeNode(aNode).data,fData);
end;

procedure TGenericStringBinaryTreeNode.streamNodeOut(aWriter:TWriter);
begin
  aWriter.WriteString(fData);
end;

procedure TGenericStringBinaryTreeNode.streamNodeIn(aReader:TReader);
begin
  fData:=aReader.ReadString;
end;

function TGenericStringBinaryTreeNode.getDataSize: integer;
begin
  result:=stringSize(fData);
end;

procedure TGenericStringBinaryTreeNode.initNode;
begin
  fData:='';
end;

end.
