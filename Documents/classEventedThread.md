# classEventedThread.pas #

## Introduction ##
If you've never used threads before, you will probably not have encountered compiler messages telling you that the thread methods 'suspend' and 'resume' are deprecated.  If you have used threads, and have relied on suspend and resume to manage the thread, then you may be in a spot of bother... especially if you've never used Windows eventing before.

This thread class provides a base on which to build threads that can be suspended and resumed properly.

## Usage ##

For most applications, all you have to do is master 'create', 'pause', 'unpause' and 'terminate'.

    constructor create(createPaused:boolean=true;singlePass:boolean=false;unpauseTimeout:cardinal=INFINITE;synchronizeEvents:boolean=true;synchronizeFinish:boolean=true)

Create takes four parameters:-

- **createPaused** - This is akin to the standard 'createSuspended' parameter, except every thread created from this class will be running as soon as it is created.  Setting this parameter to true will put the thread in the paused state as soon as it starts, allowing you to perform any additional setup required before actual processing takes place.
- **singlePass** - Sometimes you want a thread that will run once and stop.  This class contains a permanent loop that is hidden from you within the 'execute' method.  Setting this parameter to true will allow you to make use of the 'createPaused' functionality but still have the thread terminate after a single cycle.
- **unpauseTimeout** - Sometimes periodic processing is required.  You could handle this manually yourself by calling 'unpause', but by setting this to a value in milliseconds, the thread will wake itself up automatically and (depending on the 'autoPause' property) go back to sleep.  You can also wake the thread up manually by calling 'unpause'.  The default value of 'INFINITE' means the thread will only wake up when you call 'unpause'.
- **synchronizeEvents** - If you are planning on using the events 'onPaused', 'onUnpaused', 'onCycleBefore' and 'onCycleAfter' you will need to consider the context in which the events are invoked.  By default this parameter is true which means they will be invoked in the context of the application message handling thread (typically the main thread), if this is false, they will be invoked in the context of the thread itself.
- **synchronizeFinish** - This parameter operates in the same manner as 'synchronizeEvents' but affects on the 'onExecutionFinished' event.  By default this event will be synchronized like ths others.


    procedure unpause;

Calling 'unpause' will wake the thread.  If the 'autopause' property is true, a single cycle will execute and the thread will then enter the paused state again assuming it is not terminated in the meantime.

    procedure pause;

Calling 'pause' will put the thread to sleep.  If you specified an 'unpauseTimeout' when you created the thread it will wake automatically after that period.

    procedure terminate;

Calling 'terminate' will put the thread in shut down mode and it will exit the internal 'execute' method.

## Events ##

This thread class provides the following events:-

- **onExecutionFinished** - Occurs when the thread is terminating.  The standard 'onTerminate' event of TThread is somewhat unreliable, especially if the thread encounters an exception
- **onCycleBefore** - Occurs before the 'doExecute' method is called
- **onCycleAtfer** - Occurs after the 'doExecuted' method has finished
- **onPaused** - Occurs when the thread enters the paused state
- **onUnpaused** - Occurs when the thread leaves the paused state

**NOTE:-** All events occur in the context of the main thread by default (i.e. they use synchronize).  This can be configured using the 'synchronizeEvents' and 'synchronizeFinish' parameters of the constructor.  The onlt exception to this rule is 'onExecutionFinished' which is ALWAYS called in the context of the thread itself.

## Making It Do Stuff ##

With a standard TThread, you have to implement the protected 'Execute' method.  In this class, this is already overriden to provide (and hide) the pause/unpause functionality from you.  So you need a mechanism to tell your thread what to do.

This is provided by the virtual abstract method 'doExecute'.

When writing this, you should view your task as 'what do I want this thread to do in a single cycle'.  Typically a thread will include a 'while not terminated' loop into which you stuff the code you want executed.  'doExecute' is where that code should now go.

If you want your thread to pause, simply call 'pause' and the thread will go to sleep at the end of the current cycle.  If you want it to terminate, call 'terminate'.  Just don't think that you need to include your own loop in there.  You can, but then you won't be able to make use of the pause functionality... of course that may be fine, you may not need it once you've started your thread.

## Final Notes ##

Multi-threaded programming has been made easier recently with the inclusion of the parallel programming library, but sometimes you just want some good old fashioned thread action.  This class is designed to fill the void left by the deprecation of 'suspend' and 'resume'.  I get the impression from things I've read that we were never supposed to use them, but when you're just starting out and you just don't get Windows eventing (I struggled with it for a very long time), they are your friend as you can manage your threads.

This class provides mechanisms akin to suspend and resume to make it easy for you to manage thread activity and also address some of the flakiness that exists with the onTerminate event.

Multi-threaded programming has the reputation of being a very complicated black art that only the most skilled should indulge in.  Sure it's a little tricky, but give it a go.  With most people having multi-core machines (when I first dabbled with it, it was only server grade machines that had multiple cores - although back then it was mutiple physical CPUs) you can really get some benefits particularly for background processing of data.  The example program provides a demonstration of using this class in the form of three threads.  Two pausable (100ms cycle time and 0-999ms cycle time with events) and one auto-pause auto-wakeup.

## Version History ##

    Date        Version Author                 Description
    ----------- ------- ---------------------- ----------------------------------------------------------
    21-Dec-2014 1.0      C L Warne             Original release
    ----------- ------- ---------------------- ----------------------------------------------------------