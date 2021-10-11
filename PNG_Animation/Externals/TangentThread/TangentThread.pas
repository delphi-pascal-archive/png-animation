unit TangentThread;

interface

uses
  Windows,
  Classes,
  Forms;

type
  TRuntimeCheck=function: Boolean of Object;

  TMyThread = class(TThread)
   private
    FInterval: Cardinal;
    FOnExecute: TNotifyEvent;
    FRuntimeCheck: TRuntimeCheck;
    procedure CentralControl;
  protected
    procedure Execute; override;
  end;

  TTangentThread = class(TComponent)
  private
    FThread: TMyThread;
    FInterval: Cardinal;
    FTerminateWait: Cardinal;
    FActive: Boolean;
    FPriority: TThreadPriority;
    FOnSuspend: TNotifyEvent;
    FOnResume: TNotifyEvent;
    FOnExecute: TNotifyEvent;
    FOnTerminate: TNotifyEvent;
    procedure SetInterval(Value: Cardinal);
    procedure SetPriority(Value: TThreadPriority);
    procedure SetActive(Value: Boolean);
    procedure SetOnExecute(Value: TNotifyEvent);
    function GetThreadHandle: Cardinal;
    function GetThreadID: Cardinal;
    function IsRuntime: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Interval: Cardinal read FInterval write SetInterval;
    property TerminateWait: Cardinal read FTerminateWait write FTerminateWait;
    property Priority: TThreadPriority read FPriority write SetPriority;
    property Active: Boolean read FActive write SetActive;
    property ThreadHandle: Cardinal read GetThreadHandle;
    property ThreadID: Cardinal read GetThreadID;
    property OnSuspend: TNotifyEvent read FOnSuspend write FOnSuspend;
    property OnResume: TNotifyEvent read FOnResume write FOnResume;
    property OnExecute: TNotifyEvent read FOnExecute write SetOnExecute;
    property OnTerminate: TNotifyEvent read FOnTerminate write FOnTerminate;
  end;

  PTangentThread = ^TTangentThread;

{-------------------------------------------------------------------------------
------------------------------- TTHREADLISTEX ----------------------------------
-------------------------------------------------------------------------------}

type TThreadListEx = class
 private
  FList: TList;
  function GetCount: Cardinal;
  function GetCapacity: Cardinal;
  procedure SetCapacity(Value: Cardinal);
  function GetThread(Index: Integer): TTangentThread;
 public
  constructor Create; reintroduce;
  destructor Destroy; override;
  function AddNew: TTangentThread;
  procedure Add(var Thread: TTangentThread);
  procedure Insert(At: Integer; var Thread: TTangentThread);
  function Extract(At: Integer): TTangentThread;
  procedure Delete(At: Integer);
  procedure SetNil(At: Integer);
  procedure Exchange(Src, Dest: Integer);
  procedure Pack;
  procedure Clear;
  property Count: Cardinal read GetCount;
  property Capacity: Cardinal read GetCapacity write SetCapacity;
  property Threads[Index: Integer]: TTangentThread read GetThread;
 end;

procedure Register;

implementation

procedure Register;
begin
 RegisterComponents('Tangent Non-Visual', [TTangentThread]);
end;

procedure TMyThread.CentralControl;
begin
 if (FRuntimeCheck) and Assigned(FOnExecute) then FOnExecute(self);
end;

procedure TMyThread.Execute;
begin
 repeat
  Sleep(FInterval);
  if Terminated then Break;
  Synchronize(CentralControl);
 until Terminated;
end;

function TTangentThread.IsRuntime: Boolean;
begin
 Result := not (csDesigning in ComponentState);
end;

procedure TTangentThread.SetOnExecute(Value: TNotifyEvent);
begin
 if @Value <> @FOnExecute then
  begin
   FOnExecute := Value;
   FThread.FOnExecute := Value;
  end;
end;

procedure TTangentThread.SetInterval(Value: Cardinal);
begin
 if Value <> FInterval then
  begin
   FInterval := Value;
   FThread.FInterval := Value;
  end;
end;

procedure TTangentThread.SetPriority(Value: TThreadPriority);
begin
 if Value <> FPriority then
  begin
   FPriority := Value;
   FThread.Priority := Value;
  end;
end;

procedure TTangentThread.SetActive(Value: Boolean);
begin
 if Value <> FActive then
  begin
   FActive := Value;
   case FActive of
    False:
     begin
      FThread.Suspend;
      if (IsRuntime) and (Assigned(FOnSuspend)) then FOnSuspend(self);
     end;
    True:
     begin
      FThread.Resume;
      if (IsRuntime) and (Assigned(FOnResume)) then FOnResume(self);
     end;
   end;
  end;
end;

function TTangentThread.GetThreadHandle: Cardinal;
begin
 Result := FThread.Handle;
end;

function TTangentThread.GetThreadID: Cardinal;
begin
 Result := FThread.ThreadID;
end;

constructor TTangentThread.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 FThread := TMyThread.Create(True);
 FThread.FRuntimeCheck := IsRuntime;
 TerminateWait := 5000;
 FThread.FInterval := 1000;
 FActive := False;
 FInterval := 1000;
 FPriority := tpNormal;
 FThread.Priority := tpNormal;
end;

destructor TTangentThread.Destroy;
Var
 S: Cardinal;
 T: Cardinal;
begin
 if Assigned(FOnTerminate) then FOnTerminate(self);
 FThread.Terminate;
 S := GetTickCount;
 while not FThread.Terminated do
  begin
   T := GetTickCount;
   if T - S < TerminateWait then
    FThread.Free;
  end;
 inherited Destroy;
end;

{-------------------------------------------------------------------------------
------------------------------- TTHREADLISTEX ----------------------------------
-------------------------------------------------------------------------------}

constructor TThreadListEx.Create;
begin
 inherited Create;
 FList := TList.Create;
end;

destructor TThreadListEx.Destroy;
Var
 I: Integer;
begin
 for I := 0 to FList.Count - 1 do
  TTangentThread(FList.Items[I]^).Free;
 FList.Free;
 inherited Destroy;
end;

function TThreadListEx.GetCount: Cardinal;
begin
 Result := FList.Count;
end;

function TThreadListEx.GetCapacity: Cardinal;
begin
 Result := FList.Capacity;
end;

procedure TThreadListEx.SetCapacity(Value: Cardinal);
begin
 FList.Capacity := Value;
end;

function TThreadListEx.GetThread(Index: Integer): TTangentThread;
begin
 Result := TTangentThread(FList.Items[Index]^);
end;

function TThreadListEx.AddNew: TTangentThread;
begin
 Result := TTangentThread.Create(nil);
 FList.Add(Result);
end;

procedure TThreadListEx.Add(var Thread: TTangentThread);
begin
 if Assigned(Thread) then FList.Add(Thread);
end;

procedure TThreadListEx.Insert(At: Integer; var Thread: TTangentThread);
begin
 if Assigned(Thread) then FList.Insert(At, Thread);
end;

function TThreadListEx.Extract(At: Integer): TTangentThread;
begin
 Result := TTangentThread(FList.Items[At]^);
 FList.Items[At] := nil;
end;

procedure TThreadListEx.Delete(At: Integer);
begin
 TTangentThread(FList.Items[At]).Free;
 FList.Delete(At);
end;

procedure TThreadListEx.SetNil(At: Integer);
begin
 TTangentThread(FList.Items[At]).Free;
 FList.Items[At] := nil;
end;

procedure TThreadListEx.Exchange(Src, Dest: Integer);
begin
 FList.Exchange(Src, Dest);
end;

procedure TThreadListEx.Pack;
begin
 FList.Pack;
end;

procedure TThreadListEx.Clear;
Var
 I: Integer;
begin
 for I := 0 to FList.Count - 1 do
  TTangentThread(FList.Items[I]).Free;
 FList.Clear;
end;

end.