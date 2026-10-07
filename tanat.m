// tanat [command...]: keep the Mac awake, lid closed included, until Ctrl-C or until command exits.
// tanat --bar: menu bar icon, left click toggles, right click to quit.
// Build: cc -O2 -fobjc-arc -framework Cocoa -framework IOKit -o ~/.local/bin/tanat tanat.m
#import <Cocoa/Cocoa.h>
#include <IOKit/pwr_mgt/IOPMLibDefs.h>

@interface Bar : NSObject
@property NSStatusItem *item;
@property NSMenu *menu;
@property NSTask *task;
@end

@implementation Bar
- (instancetype)init {
  self = [super init];
  _item = [NSStatusBar.systemStatusBar statusItemWithLength:NSSquareStatusItemLength];
  _item.button.target = self, _item.button.action = @selector(click);
  [_item.button sendActionOn:NSEventMaskLeftMouseUp | NSEventMaskRightMouseUp];
  _menu = [NSMenu new];
  [_menu addItemWithTitle:@"Quit tanat" action:@selector(terminate:) keyEquivalent:@"q"].target = NSApp;
  [self update];
  return self;
}
- (void)update {
  _item.button.image = [NSImage imageWithSystemSymbolName:_task.running ? @"cup.and.saucer.fill" : @"cup.and.saucer" accessibilityDescription:@"tanat"];
}
- (void)click {
  if (NSApp.currentEvent.type == NSEventTypeRightMouseUp) {
    _item.menu = _menu, [_item.button performClick:nil], _item.menu = nil;
  } else if (_task.running) {
    [_task terminate];
  } else {  // the session waits on our pid, so it ends with us whatever happens
    _task = [NSTask new];
    _task.executableURL = [NSURL fileURLWithPath:NSBundle.mainBundle.executablePath];
    _task.arguments = @[ @"caffeinate", @"-w", @(getpid()).stringValue ];
    __weak Bar *weak = self;
    _task.terminationHandler = ^(NSTask *t) { dispatch_async(dispatch_get_main_queue(), ^{ [weak update]; }); };
    [_task launchAndReturnError:nil];
    [self update];
  }
}
@end

int main(int argc, char **argv) {
  if (argc == 2 && !strcmp(argv[1], "--bar")) {
    NSApplication.sharedApplication.activationPolicy = NSApplicationActivationPolicyAccessory;
    __unused Bar *bar = [Bar new];
    [NSApp run];
  }
  pid_t self = getpid();
  if (fork() == 0) {  // watchdog: blocks lid sleep while we live, restores it once we die, however we die
    setsid();
    signal(SIGINT, SIG_IGN), signal(SIGHUP, SIG_IGN), signal(SIGTERM, SIG_IGN);
    io_connect_t pm;
    IOServiceOpen(IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPMrootDomain")), mach_task_self(), 0, &pm);
    uint64_t on = 1, off = 0;
    uint32_t n = 0;
    while (getppid() == self) IOConnectCallScalarMethod(pm, kPMSetClamshellSleepState, &on, 1, NULL, &n), usleep(100000);
    IOConnectCallScalarMethod(pm, kPMSetClamshellSleepState, &off, 1, NULL, &n);
    return 0;
  }
  if (argc == 1) puts("tanat: staying awake until Ctrl-C");
  char *args[argc + 2];
  args[0] = "caffeinate", args[1] = "-dims";
  memcpy(args + 2, argv + 1, argc * sizeof *argv);
  execvp(args[0], args);
  perror("caffeinate");
  return 1;
}
