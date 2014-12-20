unit formBTreeTestbedMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, unitGenericBinaryTree, CodeSiteLogging, ExtCtrls, System.UITypes;

const
  TOTAL = 500000;

  NUMTHREADS = 2;
  PERTHREAD = TOTAL DIV NUMTHREADS;
  THREADRANGE = (8 DIV NUMTHREADS)*PERTHREAD;
  NUMBER = PERTHREAD*NUMTHREADS;

  NUMSEARCHTHREADS = 2;
  PERSEARCHTHREAD = TOTAL DIV NUMSEARCHTHREADS;
  SEARCHTHREADRANGE = (8 DIV NUMSEARCHTHREADS)*PERSEARCHTHREAD;
  SEARCHNUMBER = PERSEARCHTHREAD*NUMSEARCHTHREADS;

type
  TfrmBTreeTestbedMain = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    Button20: TButton;
    Button21: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button21Click(Sender: TObject);
  private
    { Private declarations }
    fBinaryTree : TGenericBinaryTree<TGenericIntegerBinaryTreeNode>;

    fSTree      : TGenericBinaryTree<TGenericStringBinaryTreeNode>;

    fLastNode   : integer;
  public
    { Public declarations }
    procedure dumpNode(aNode:TGenericIntegerBinaryTreeNode;var abort:boolean);
    procedure checkNode(aNode:TGenericIntegerBinaryTreeNode;var abort:boolean);
  end;

  TLoadThread = class(TThread)
  protected
    fAttempts   : integer;
    fBinaryTree : TGenericBinaryTree<TGenericIntegerBinaryTreeNode>;
    fMemo       : TMemo;

    procedure Execute; override;
  public
    constructor create(aTree:TGenericBinaryTree<TGenericIntegerBinaryTreeNode>;aMemo:TMemo);
    procedure loadDone;
  end;

  TUnsafeLoadThread = class(TThread)
  protected
    fAttempts   : integer;
    fBinaryTree : TGenericBinaryTree<TGenericIntegerBinaryTreeNode>;
    fMemo       : TMemo;

    procedure Execute; override;
  public
    constructor create(aTree:TGenericBinaryTree<TGenericIntegerBinaryTreeNode>;aMemo:TMemo);
    procedure loadDone;
  end;

  TFindThread = class(TThread)
  protected
    fFound      : integer;
    fBinaryTree : TGenericBinaryTree<TGenericIntegerBinaryTreeNode>;
    fMemo       : TMemo;
    procedure Execute; override;
  public
    constructor create(aTree:TGenericBinaryTree<TGenericIntegerBinaryTreeNode>;aMemo:TMemo);
    procedure findDone;
  end;

  TLoadStringsThread = class(TThread)
  protected
    fMemo       : TMemo;
    fSTree      : TGenericBinaryTree<TGenericStringBinaryTreeNode>;
    fAttempts   : integer;
    fLoop       : integer;
    procedure Execute; override;
  public
    constructor create(sTree:TGenericBinaryTree<TGenericStringBinaryTreeNode>;aMemo:TMemo);
    procedure loadDone;
    procedure progress;
  end;

  TFindStringsThread = class(TThread)
  protected
    fFound      : integer;
    fMemo       : TMemo;
    fSTree      : TGenericBinaryTree<TGenericStringBinaryTreeNode>;
    fLoop       : integer;
    procedure Execute; override;
  public
    constructor create(sTree:TGenericBinaryTree<TGenericStringBinaryTreeNode>;aMemo:TMemo);
    procedure findDone;
    procedure progress;
  end;



var
  frmBTreeTestbedMain: TfrmBTreeTestbedMain;

implementation

{$R *.dfm}

procedure TfrmBTreeTestbedMain.Button10Click(Sender: TObject);
begin
  memo1.lines.add('Loading '+intToStr(PERTHREAD)+' Finding '+intToStr(PERTHREAD)+' items');
  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now));

  with TLoadThread.create(fBinaryTree,memo1) do
  begin
    resume;
  end;
  with TFindThread.create(fBinaryTree,memo1) do
  begin
    resume;
  end;
end;

procedure TfrmBTreeTestbedMain.Button11Click(Sender: TObject);
begin
  fSTree.clear;
end;

procedure TfrmBTreeTestbedMain.Button12Click(Sender: TObject);
var
  abort : boolean;
begin
  abort:=false;
  fBinaryTree.traverseLCR(fBinaryTree.root,dumpNode,abort);
end;

procedure TfrmBTreeTestbedMain.Button13Click(Sender: TObject);
var
  loop    : integer;
  aNode   : TGenericIntegerBinaryTreeNode;
  count   : integer;
begin
  // Delete test
  memo1.lines.add('Deleting '+intToStr(NUMBER div 2)+' items');
  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now));

  aNode:=fBinaryTree.createNode(false);
  count:=0;

  for loop:=1 to (NUMBER div 2) do
  begin
    aNode.data:=random(THREADRANGE);

    if (fBinaryTree.deleteNodeSafe(aNode)) then
    begin
      inc(count);
    end;
  end;

  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - Delete done - Deleted '+intToStr(count));
end;

procedure TfrmBTreeTestbedMain.Button14Click(Sender: TObject);
var
  abort : boolean;
begin
  fLastNode:=-1;
  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - Checking integrity');
  fBinaryTree.traverseLCR(fBinaryTree.root,checkNode,abort);
  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - Checking completed');


  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - Internal integrity check');
  try
    fBinaryTree.checkIntegrity;
  except
    on E:EGenericBinaryTreeException do
    begin
      memo1.lines.add('BTree Error - '+e.message);
    end;
    on E:Exception do
    begin
      memo1.lines.add('Exception ('+e.className+') - '+e.message);
    end;
  end;
  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - Internal integrity check completed');
end;

procedure TfrmBTreeTestbedMain.Button15Click(Sender: TObject);
begin
  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - Balancing');
  fBinaryTree.balance;
  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - Balancing complete');
end;

procedure TfrmBTreeTestbedMain.Button16Click(Sender: TObject);
begin
  if (NUMTHREADS=1) then
  begin
    memo1.lines.add('Unsafe loading '+intToStr(NUMBER)+' items');
    memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now));

    with TUnsafeLoadThread.create(fBinaryTree,memo1) do
    begin
      resume;
    end;
  end
  else
  begin
    messageDlg('Cannot use unsafe populate with multiple threads!',mtError,[mbOK],0);
  end;
end;

procedure TfrmBTreeTestbedMain.Button17Click(Sender: TObject);
begin
  memo1.lines.add('String Stats');
  fSTree.toStringsSafe(memo1.lines);
end;

procedure TfrmBTreeTestbedMain.Button18Click(Sender: TObject);
begin
  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - String Balancing');
  fSTree.balance;
  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - String Balancing complete');
end;

procedure TfrmBTreeTestbedMain.Button19Click(Sender: TObject);
begin
  fSTree.clearSearchStats;
end;

procedure TfrmBTreeTestbedMain.checkNode(aNode:TGenericIntegerBinaryTreeNode;var abort:boolean);
var
  parentNode : TGenericIntegerBinaryTreeNode;
  node       : TGenericIntegerBinaryTreeNode;
begin
  node:=TGenericIntegerBinaryTreeNode(aNode);
  parentNode:=TGenericIntegerBinaryTreeNode(aNode.parent);

  if (node.data<=fLastNode) then
  begin
    memo1.lines.add('Inconsistency found (Previous '+intToStr(fLastNode)+'), Current '+intToStr(node.data));
    abort:=true;
  end;

  if (parentNode<>nil) then
  begin
    if (node.data>parentNode.data) then
    begin
      if (parentNode.right<>node) then
      begin
        memo1.lines.add('Inconsistent parent right (Parent '+intToStr(parentNode.data)+'), Current '+intToStr(node.data));
        abort:=true;
      end;
    end
    else
    begin
      if (parentNode.left<>node) then
      begin
        memo1.lines.add('Inconsistent parent left (Parent '+intToStr(parentNode.data)+'), Current '+intToStr(node.data));
        abort:=true;
      end;
    end;
  end;

  fLastNode:=TGenericIntegerBinaryTreeNode(aNode).data;
end;

procedure TfrmBTreeTestbedMain.dumpNode(aNode:TGenericIntegerBinaryTreeNode;var abort:boolean);
begin
  memo1.lines.add(intToStr(TGenericIntegerBinaryTreeNode(aNode).data));
end;

procedure TfrmBTreeTestbedMain.Button1Click(Sender: TObject);
begin
  fBinaryTree:=TGenericBinaryTree<TGenericIntegerBinaryTreeNode>.create;
end;

procedure TfrmBTreeTestbedMain.Button20Click(Sender: TObject);
begin
  fBinaryTree.clear;
end;

procedure TfrmBTreeTestbedMain.Button21Click(Sender: TObject);
var
  buf   : TStringList;
  loop  : integer;
  idx   : integer;
  vals  : string;
  found : integer;
begin
  buf:=TStringList.create;
  try
    memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - Test load of 500K into TStringList');

    buf.sorted:=true;
    buf.capacity:=500000;

    for loop:=1 to 500000 do
    begin
      repeat
        vals:=intToHex(random(2000000),8);
        idx:=buf.IndexOf(vals);
      until (idx<0);

      buf.add(vals);

      if (loop mod 10000=0) then
      begin
        memo1.lines.add(intToStr(loop)+' done');
        application.processMessages;
      end;
    end;

    memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - Test load of 500K into TStringList completed');

    memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - Test find of 500K in TStringList');

    found:=0;
    for loop:=1 to 500000 do
    begin
      vals:=intToHex(random(2000000),8);

      if (buf.indexOf(vals)>=0) then
      begin
        inc(found);
      end;

      if (loop mod 10000=0) then
      begin
        memo1.lines.add(intToStr(loop)+' done');
        application.processMessages;
     end;
    end;

    memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - Test find of 500K in TStringList completed ('+intToStr(found)+' found)');

  finally
    buf.free;
  end;
end;

procedure TfrmBTreeTestbedMain.Button2Click(Sender: TObject);
var
  loop      : integer;
begin
  memo1.lines.add('Loading '+intToStr(NUMBER)+' items');
  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now));

  for loop:=1 to NUMTHREADS do
  begin
    with TLoadThread.create(fBinaryTree,memo1) do
    begin
      resume;
    end;
  end;
end;

procedure TfrmBTreeTestbedMain.Button3Click(Sender: TObject);
begin
  fBinaryTree.free;
end;

procedure TfrmBTreeTestbedMain.Button4Click(Sender: TObject);
begin
  fBinaryTree.toStringsSafe(memo1.lines);
end;

procedure TfrmBTreeTestbedMain.Button5Click(Sender: TObject);
begin
  fBinaryTree.clearSearchStats;
end;

procedure TfrmBTreeTestbedMain.Button6Click(Sender: TObject);
var
  loop      : integer;
begin
  memo1.lines.add('Finding '+intToStr(SEARCHNUMBER)+' items');
  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now));

  for loop:=1 to NUMSEARCHTHREADS do
  begin
    with TFindThread.create(fBinaryTree,memo1) do
    begin
      resume;
    end;
  end;
end;

procedure TfrmBTreeTestbedMain.Button7Click(Sender: TObject);
var
  loop : integer;
begin
  memo1.lines.add('String Loading '+intToStr(NUMBER)+' items');
  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now));

  for loop:=1 to NUMTHREADS do
  begin
    with TLoadStringsThread.create(fSTree,memo1) do
    begin
      resume;
    end;
  end;
end;

procedure TfrmBTreeTestbedMain.Button8Click(Sender: TObject);
var
  loop : integer;
begin
  memo1.lines.add('String Finding '+intToStr(NUMBER)+' items');
  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now));

  for loop:=1 to NUMTHREADS do
  begin
    with TFindStringsThread.create(fSTree,memo1) do
    begin
      resume;
    end;
  end;

end;

procedure TfrmBTreeTestbedMain.Button9Click(Sender: TObject);
begin
  memo1.lines.add('String Loading '+intToStr(PERTHREAD)+', Finding '+intToStr(PERTHREAD)+' items');
  memo1.lines.add(formatDateTime('hh:mm:ss.zzz',now));

  with TLoadStringsThread.create(fSTree,memo1) do
  begin
    resume;
  end;
  with TFindStringsThread.create(fSTree,memo1) do
  begin
    resume;
  end;
end;

procedure TfrmBTreeTestbedMain.FormCreate(Sender: TObject);
begin
  fSTree:=TGenericBinaryTree<TGenericStringBinaryTreeNode>.create;
end;

procedure TfrmBTreeTestbedMain.FormDestroy(Sender: TObject);
begin
  fSTree.free;
end;

procedure TfrmBTreeTestbedMain.FormShow(Sender: TObject);
begin

end;

{ TLoadThread }

constructor TLoadThread.create(aTree: TGenericBinaryTree<TGenericIntegerBinaryTreeNode>;aMemo:TMemo);
begin
  inherited create(true);

  self.freeOnTerminate:=true;
  fBinaryTree:=aTree;
  fAttempts:=0;
  fMemo:=aMemo;
end;

procedure TLoadThread.execute;
var
  aNode     : TGenericIntegerBinaryTreeNode;
  loop      : integer;
begin
  fAttempts:=0;
  for loop:=1 to PERTHREAD do
  begin
    aNode:=fBinaryTree.createNodeSafe;

    repeat
      aNode.data:=random(THREADRANGE);
      inc(fAttempts);
    until (fBinaryTree.placeNodeSafe(aNode));
  end;

  synchronize(loadDone);
end;

procedure TLoadThread.loadDone;
begin
  fMemo.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - Load thread $'+intToHex(int64(self),8)+' - Done - Attempts '+intToStr(fAttempts));
end;

{ TFindThread }

constructor TFindThread.create(aTree: TGenericBinaryTree<TGenericIntegerBinaryTreeNode>; aMemo: TMemo);
begin
  inherited create(true);

  self.freeOnTerminate:=true;
  fBinaryTree:=aTree;
  fFound:=0;
  fMemo:=aMemo;
end;

procedure TFindThread.execute;
var
  loop    : integer;
  aNode   : TGenericIntegerBinaryTreeNode;
  pNode   : TGenericIntegerBinaryTreeNode;
  node    : TGenericIntegerBinaryTreeNode;
  lastComp: integer;
begin
  aNode:=fBinaryTree.createNode(false);

  fFound:=0;
  for loop:=1 to PERSEARCHTHREAD do
  begin
    aNode.data:=random(SEARCHTHREADRANGE);

    fBinaryTree.findSafe(aNode,pNode,node,lastComp);

    if (node<>nil) then
    begin
      inc(fFound);
    end;
  end;

  aNode.free;

  synchronize(findDone);
end;

procedure TFindThread.findDone;
begin
  fMemo.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - Find thread $'+intToHex(int64(self),8)+' - Done - Found '+intToStr(fFound));
end;

{ TLoadStringsThread }

constructor TLoadStringsThread.create(sTree:TGenericBinaryTree<TGenericStringBinaryTreeNode>; aMemo: TMemo);
begin
  inherited create(true);

  fSTree:=sTree;
  fMemo:=aMemo;
  fAttempts:=0;
end;

procedure TLoadStringsThread.Execute;
var
  loop  : integer;
  vals  : string;
  aNode : TGenericStringBinaryTreeNode;
begin
  fAttempts:=0;

  for loop:=1 to PERTHREAD do
  begin
    aNode:=fSTree.createNodeSafe;

    repeat
      vals:=intToHex(random(THREADRANGE),8);
      aNode.data:=vals;
      inc(fAttempts);
    until (fSTree.placeNodeSafe(aNode));
  end;

  synchronize(loadDone);
end;

procedure TLoadStringsThread.loadDone;
begin
  fMemo.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - String Load thread $'+intToHex(int64(self),8)+' - Done - Attempts '+intToStr(fAttempts));
end;

procedure TLoadStringsThread.progress;
begin
  fMemo.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - String Load thread $'+intToHex(int64(self),8)+' - '+intToStr(fLoop));
end;

{ TFindStringsThread }

constructor TFindStringsThread.create(sTree:TGenericBinaryTree<TGenericStringBinaryTreeNode>;aMemo: TMemo);
begin
  inherited create(true);

  fSTree:=sTree;
  fMemo:=aMemo;
  fFound:=0;
end;

procedure TFindStringsThread.execute;
var
  loop : integer;
  valS : string;
  aNode : TGenericStringBinaryTreeNode;
  pNode : TGenericStringBinaryTreeNode;
  node : TGenericStringBinaryTreeNode;
  lastComp : integer;
begin
  aNode:=fSTree.createNode(false);

  for loop:=1 to PERSEARCHTHREAD do
  begin
    vals:=intToHex(random(SEARCHTHREADRANGE),8);
    aNode.data:=vals;

    fSTree.findSafe(aNode,pNode,node,lastComp);

    if (node<>nil) then
    begin
      inc(fFound);
    end;
  end;

  synchronize(findDone);
end;

procedure TFindStringsThread.findDone;
begin
  fMemo.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - String Find thread $'+intToHex(int64(self),8)+' - Done - Found '+intToStr(fFound));
end;

procedure TFindStringsThread.progress;
begin
  fMemo.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - String Find thread $'+intToHex(int64(self),8)+' - '+intToStr(fLoop));
end;

{ TUnsafeLoadThread }

constructor TUnsafeLoadThread.create(aTree: TGenericBinaryTree<TGenericIntegerBinaryTreeNode>; aMemo: TMemo);
begin
  inherited create(true);

  self.freeOnTerminate:=true;
  fBinaryTree:=aTree;
  fAttempts:=0;
  fMemo:=aMemo;
end;

procedure TUnsafeLoadThread.Execute;
var
  aNode     : TGenericIntegerBinaryTreeNode;
  loop      : integer;
  done      : boolean;
begin
  for loop:=1 to PERTHREAD do
  begin
    aNode:=fBinaryTree.createNode;

    repeat
      aNode.data:=random(THREADRANGE);
      done:=fBinaryTree.placeNode(aNode);
      inc(fAttempts);
    until (done);
  end;

  synchronize(loadDone);
end;

procedure TUnsafeLoadThread.loadDone;
begin
  fMemo.lines.add(formatDateTime('hh:mm:ss.zzz',now)+' - Unsafe Load thread $'+intToHex(int64(self),8)+' - Done - Attempts '+intToStr(fAttempts));
end;

end.
