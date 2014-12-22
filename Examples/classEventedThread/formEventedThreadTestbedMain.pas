unit formEventedThreadTestbedMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, classEventedThread, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TfrmEventedThreadTestbedMain = class(TForm)
    mmoLog: TMemo;
    pnlControlContainer: TPanel;
    cmdUnpause: TButton;
    cmdPause: TButton;
    cmdUnpauseSingle: TButton;
    procedure cmdUnpauseClick(Sender: TObject);
    procedure cmdPauseClick(Sender: TObject);
    procedure cmdUnpauseSingleClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    type
      TPausableThread1 = class(TEventedThread) // Sleeps for 100ms after each sync
      protected
        fData : integer;
        procedure doExecute; override;
        procedure sync;
      public
        constructor create;
      end;

      TPausableThread2 = class(TEventedThread) // Sleeps for random(1000)ms after each sync
      protected
        fData : integer;
        procedure doExecute; override;
        procedure sync;
      public
        constructor create;
      end;

      TRunOnceThread = class(TEventedThread) // Automatically pauses after each sync.  Unpause wakes.  Runs automatically 10s after last pause
      protected
        fData : integer;
        procedure doExecute; override;
        procedure sync;
      public
        constructor create;
      end;
  protected
    fPausable1  : TPausableThread1;
    fPausable2  : TPausableThread2;
    fSingle     : TRunOnceThread;
  public
    { Public declarations }
  end;

var
  frmEventedThreadTestbedMain: TfrmEventedThreadTestbedMain;

implementation

{$R *.dfm}

procedure TfrmEventedThreadTestbedMain.cmdPauseClick(Sender: TObject);
begin
  fPausable1.pause;
  fPausable2.pause;
end;

procedure TfrmEventedThreadTestbedMain.cmdUnpauseClick(Sender: TObject);
begin
  fPausable1.unpause;
  fPausable2.unpause;
end;

procedure TfrmEventedThreadTestbedMain.cmdUnpauseSingleClick(Sender: TObject);
begin
  fSingle.unpause;
end;

procedure TfrmEventedThreadTestbedMain.FormCreate(Sender: TObject);
begin
  fPausable1:=TPausableThread1.create;
  fPausable2:=TPausableThread2.create;
  fSingle:=TRunOnceThread.create;
end;

procedure TfrmEventedThreadTestbedMain.FormDestroy(Sender: TObject);
begin
  fPausable1.terminate;
  fPausable1.waitFor;
  fPausable1.free;

  fPausable2.terminate;
  fPausable2.waitFor;
  fPausable2.free;

  fSingle.terminate;
  fSingle.waitFor;
  fSingle.free;
end;

//------------------------------------------------------------------------------

{ TfrmEventedThreadTestbedMain.TPausableThread }

constructor TfrmEventedThreadTestbedMain.TPausableThread1.create;
begin
  fData:=0;

  inherited create(true);

  self.freeOnTerminate:=false;
end;

procedure TfrmEventedThreadTestbedMain.TPausableThread1.doExecute;
begin
  inc(fData);
  sync;
  sleep(100);
end;

procedure TfrmEventedThreadTestbedMain.TPausableThread1.sync;
begin
  frmEventedThreadTestbedMain.mmoLog.lines.add('Pausable thread 1 - '+intToStr(fData));
end;

{ TfrmEventedThreadTestbedMain.TRunOnceThread }

constructor TfrmEventedThreadTestbedMain.TRunOnceThread.create;
begin
  fData:=0;

  inherited create(true,false,10000);

  self.freeOnTerminate:=false;
  self.autoPause:=true;
end;

procedure TfrmEventedThreadTestbedMain.TRunOnceThread.doExecute;
begin
  inc(fData);
  sync;
end;

procedure TfrmEventedThreadTestbedMain.TRunOnceThread.sync;
begin
  frmEventedThreadTestbedMain.mmoLog.lines.add('Single cycle (autopause) - '+intToStr(fData));
end;

{ TfrmEventedThreadTestbedMain.TPausableThread2 }

constructor TfrmEventedThreadTestbedMain.TPausableThread2.create;
begin
  fData:=0;

  inherited create(true);

  self.freeOnTerminate:=false;
end;

procedure TfrmEventedThreadTestbedMain.TPausableThread2.doExecute;
begin
  inc(fData);
  sync;
  sleep(random(1000));
end;

procedure TfrmEventedThreadTestbedMain.TPausableThread2.sync;
begin
  frmEventedThreadTestbedMain.mmoLog.lines.add('Pausable thread 2 - '+intToStr(fData));
end;

end.
