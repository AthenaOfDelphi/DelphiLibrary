unit classSingleton;

(*

  Sub-classable Singleton
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
  classes, sysUtils;

type
  ESingletonException = class(Exception);

  TSingletonStore = class(TObject)
  protected
    fInstance       : TObject;
    fRefCount       : integer;
  public
    property instance:TObject read fInstance write fInstance;
    property refCount:integer read fRefCount write fRefCount;
  end;

  TSingleton = class(TObject)
  protected
    class procedure getSingletonStore(var sIdx:integer;var sStore:TSingletonStore);

    // These routines must be used to do the work you would normally do inside
    // the constructor and destructor (i.e. setup and teardown of local
    // variables and storage).  Failing to observe this rule will result in
    // non-functional classes
    procedure createVars; virtual; abstract;
    procedure destroyVars; virtual; abstract;
  public
    class function NewInstance:TObject; override;
    procedure FreeInstance; override;
  end;

procedure singletonStoreToStrings(dst:TStrings);

implementation

uses
  syncObjs;

var
  fSingletonStore     : TStringList;
  fSingletonStoreCS   : TCriticalSection;

procedure singletonStoreToStrings(dst:TStrings);
var
  loop : integer;
begin
  fSingletonStoreCS.acquire;
  try
    dst.add('Singleton Store Dump');
    if (fSingletonStore.count>0) then
    begin
      for loop:=0 to fSingletonStore.count-1 do
      begin
        dst.add(' $'+intToHex(nativeInt(TSingletonStore(fSingletonStore.objects[loop]).instance),8)+' - '+TSingletonStore(fSingletonStore.objects[loop]).instance.className+' ('+intToStr(TSingletonStore(fSingletonStore.objects[loop]).refCount)+')');
      end;
    end
    else
    begin
      dst.add(' - No singleton classes');
    end;
    dst.add('--------------------');
  finally
    fSingletonStoreCS.release;
  end;
end;

class procedure TSingleton.getSingletonStore(var sIdx:integer;var sStore:TSingletonStore);
var
  cName : string;
begin
  cName:=self.className;
  sIdx:=fSingletonStore.indexOf(cName);

  if (sIdx<0) then
  begin
    sStore:=nil;
  end
  else
  begin
    sStore:=TSingletonStore(fSingletonStore.objects[sIdx]);
  end;
end;

procedure TSingleton.freeInstance;
var
  sIdx    : integer;
  sStore  : TSingletonStore;
begin
  fSingletonStoreCS.acquire;
  try
    getSingletonStore(sIdx,sStore);

    if (sIdx<0) then
    begin
      raise ESingletonException.create('Attempt to free unknown singleton instance ('+self.className+')');
    end;

    sStore.refCount:=sStore.refCount-1;

    if (sStore.refCount=0) then
    begin
      fSingletonStore.delete(sIdx);

      destroyVars;

      inherited freeInstance;
    end;
  finally
    fSingletonStoreCS.release;
  end;
end;

class function TSingleton.newInstance: TObject;
var
  cName   : string;
  sIdx    : integer;
  sStore  : TSingletonStore;
begin
  fSingletonStoreCS.acquire;
  try
    getSingletonStore(sIdx,sStore);

    if (sStore=nil) then
    begin
      sStore:=TSingletonStore.create;
      sStore.refCount:=0;

      sStore.instance:=inherited newInstance;

      TSingleton(sStore.instance).createVars;

      cName:=self.className;
      fSingletonStore.addObject(cName,sStore);
    end;

    sStore.refCount:=sStore.refCount+1;
    result:=sStore.instance;
  finally
    fSingletonStoreCS.release;
  end;
end;

initialization
  fSingletonStoreCS:=TCriticalSection.create;
  fSingletonStore:=TStringList.create;

  fSingletonStore.sorted:=true;

finalization

  while (fSingletonStore.count>0) do
  begin
    try
      TSingletonStore(fSingletonStore.objects[0]).instance.free;
    except
    end;

    fSingletonStore.delete(0);
  end;

  try
    fSingletonStore.free;
  except
  end;

  try
    fSingletonStoreCS.free;
  except
  end;

end.
