unit classEventedThread;

(*

  Evented Thread
  Copyright (C) 2014 Christina Louise Warne (aka AthenaOfDelphi)

  http://athena.outer-reaches.com

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

  This unit is part of my Delphi Library (Utilities section) available at:-
    https://github.com/AthenaOfDelphi/DelphiLibrary

*)

interface

uses
  WinAPI.Windows, System.Classes;

type
  TEventedThread = class(TThread)
  protected
    fPauseHandle      : THandle;
    fUnpauseHandle    : THandle;
    fTerminateHandle  : THandle;
    fAutoPause        : boolean;
    fSinglePass       : boolean;
    fUnpauseEvents    : TWOHandleArray;
    fUnpauseTimeout   : cardinal;
    fPaused           : boolean;
    fPausing          : boolean;

    procedure Execute; override;
    procedure doExecute; virtual; abstract;
  public
    constructor create(createPaused:boolean=true;singlePass:boolean=false;unpauseTimeout:cardinal=INFINITE);
    destructor Destroy; override;

    procedure unpause;
    procedure pause;
    procedure terminate;

    property autoPause:boolean read fAutoPause write fAutoPause;

    property paused:boolean read fPaused;
    property pausing:boolean read fPausing;
    property unpauseTimeout:cardinal read fUnpauseTimeout;
  end;

implementation

{ TEventedThread }

constructor TEventedThread.create(createPaused:boolean;singlePass:boolean;unpauseTimeout:cardinal);
begin
  fPauseHandle:=CreateEvent(nil,true,createPaused,nil);
  fUnpauseHandle:=CreateEvent(nil,true,false,nil);
  fTerminateHandle:=CreateEvent(nil,true,false,nil);
  fAutoPause:=false;
  fSinglePass:=singlePass;
  fUnpauseTimeout:=unpauseTimeout;

  fUnpauseEvents[0]:=fUnpauseHandle;
  fUnpauseEvents[1]:=fTerminateHandle;

  fPaused:=false;

  inherited create(False);
end;

destructor TEventedThread.destroy;
begin
  if (not self.terminated) then
  begin
    self.terminate;
  end;

  closeHandle(fPauseHandle);
  closeHandle(fUnpauseHandle);
  closeHandle(fTerminateHandle);

  inherited;
end;

procedure TEventedThread.execute;
begin
  while (not self.terminated) do
  begin
    if (waitForSingleObject(fPauseHandle,0)=WAIT_OBJECT_0) then
    begin
      // We should pause
      fPaused:=true;
      fPausing:=false;

      if (waitForMultipleObjects(2,@fUnpauseEvents,false,fUnpauseTimeout)=WAIT_OBJECT_0) then
      begin
        resetEvent(fUnpauseHandle);
      end;

      resetEvent(fPauseHandle);

      fPaused:=false;
    end;

    if (not self.terminated) then
    begin
      doExecute;

      if (fAutoPause) then
      begin
        setEvent(fPauseHandle);
      end;

      if (fSinglePass) then
      begin
        self.terminate;
      end;
    end;
  end;
end;

procedure TEventedThread.pause;
begin
  if (not fPaused) and (not fPausing) then
  begin
    fPausing:=true;
    SetEvent(fPauseHandle);
  end;
end;

procedure TEventedThread.terminate;
begin
  if (not self.terminated) then
  begin
    TThread(self).terminate;
    SetEvent(fTerminateHandle);
  end;
end;

procedure TEventedThread.unpause;
begin
  if (fPaused) then
  begin
    SetEvent(fUnpauseHandle);
  end;
end;

end.
