//
//  ZBiM.h
//
//  ZBiM SDK Library
//
//  Copyright (c) 2014-2016, Zumobi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
#error ZBiM SDK requires min deployment target of iOS 7.0 or higher
#endif

@class ZBiMWidget;
@class CLLocation;

#pragma mark Logging

/**
 Used to set the amount of logging by the library.
 */
typedef enum : NSUInteger
{
    ZBiMLogSeverityNone = 0,
    ZBiMLogSeverityCriticalError,
    ZBiMLogSeverityError,
    ZBiMLogSeverityWarning,
    ZBiMLogSeverityInfo
} ZBiMSeverityLevel;

typedef enum : NSUInteger
{
    ZBiMLogVerbosityNone = 0,
    ZBiMLogVerbosityDebug,
    ZBiMLogVerbosityInfo
} ZBiMVerbosityLevel;

#pragma mark Error Reporting

extern NSString * const ZBIMErrorDomain;

typedef enum : NSUInteger
{
    ZBiMErrorNone = 0,
    ZBiMErrorInvalidParams,
    ZBiMErrorInvalidState,
    ZBiMErrorInvalidOperation,
    ZBiMErrorNoNetwork,
    ZBiMErrorUnknownUser,
    ZBiMErrorUserAlreadyExists,
    ZBiMErrorActiveUserNotSet,
    ZBiMErrorOperationAlreadyInProgress,
    ZBiMErrorMissingDB,
    ZBiMErrorMissingContent,
    ZBiMErrorSDKDisabledState,
    ZBiMErrorNotPartOfPilotProgram
} ZBiMError;

#pragma mark Content Hub color schemes

typedef enum : NSUInteger
{
    ZBiMColorSchemeDark = 0,
    ZBiMColorSchemeLight
} ZBiMColorScheme;

#pragma mark Content Sources

typedef enum : NSUInteger
{
    ZBiMContentSourceLocalOnly = 0,
    ZBiMContentSourceExternalAllowed
} ZBiMContentSource;

#pragma mark Content download and refresh modes

typedef enum : NSUInteger
{
    ZBiMInitialContentDownloadModeImmediate,
    ZBiMInitialContentDownloadModeOnDemand
} ZBiMInitialContentDownloadMode;

typedef enum : NSUInteger
{
    ZBiMContentRefreshModeDontShowStale,
    ZBiMContentRefreshModeStaleOK,
    ZBiMContentRefreshModeRecurring
} ZBiMContentRefreshMode;

#pragma mark ZBiM notifications

/**
 Notification indicating that download progress has a new value.
 */
extern NSString *const ZBiMDBDownloadProgressChanged;

/**
 Notification indicating that the isDownloadingContent state has changed.
 */
extern NSString *const ZBiMDownloadingContentStateChanged;

/**
 Notification indicating that the isDisplayingContentHub state has changed.
 */
extern NSString *const ZBiMDisplayingContentHubStateChanged;

/**
 Notification indicating that the isReady state has changed.
 */
extern NSString *const ZBiMReadyStateChanged;

/**
 Notification indicating that the isDisabled state has changed.
 */
extern NSString *const ZBiMDisabledStateChanged;

/**
 Notification indicating that notPartOfPilotProgram state has changed.
 */
extern NSString *const ZBiMNotPartOfPilotProgramStateChanged;

/**
 Notification indicating that the type of content being shown
 has changed.
 */
extern NSString *const ZBiMContentTypeChanged;

#pragma mark Keys and values for reading data from notifications' userInfo

// Keys and values in the ZBiMContentTypeChanged notification's userInfo dictionary,
// used to communicate the latest type of content loaded in the Content Hub.
extern NSString *const ZBiMResourceTitle;       // key for resource's title value
extern NSString *const ZBiMResourceURL;         // key for resource's URL value
extern NSString *const ZBiMResourceType;        // key for resource's type
extern NSString *const ZBiMResourceTypeHub;     // value ("hub")
extern NSString *const ZBiMResourceTypeChannel; // value ("channel")
extern NSString *const ZBiMResourceTypeArticle; // value ("article")

extern NSString *const ZBiMDownloadProgressValue; // key identifying updated progress value

#pragma mark ZBiM protocols

/**
 Allows client application to determine what it considers to
 be a relevant value for advertiser ID.
 */
@protocol ZBiMAdvertiserIdDelegate <NSObject>
- (NSString *)advertiserId;
@end

/**
 Allows client application to authorize location services on behalf of SDK.
 */
typedef void (^ZBiMLocationServiceCallback)(CLLocation *location, NSString*locationID);

@protocol ZBiMLocationServiceDelegate <NSObject>
- (void)fetchLocation:(ZBiMLocationServiceCallback)callback;
@end

/**
 Allows client application to determine what logging data to
 process and how, based on the associated logging severity
 and verbosity levels.
 */
@protocol ZBiMLoggingDelegate <NSObject>
- (void)log:(NSString *)message severityLevel:(ZBiMSeverityLevel)severityLevel verbosityLevel:(ZBiMVerbosityLevel)verbosityLevel;
@end

/**
 A protocol implemented by content hub, defining the set of
 actions accessible to client application.
 */
@protocol ZBiMContentHubDelegate <NSObject>
- (void) goBack;
- (BOOL) canGoBack;
- (void) goForward;
- (BOOL) canGoForward;
- (BOOL) dismiss:(NSError * __autoreleasing *)error;
- (void) setScrollDelegate:(id<UIScrollViewDelegate>)delegate;
- (void) setBackgroundColor:(UIColor *)color;
- (void) loadContentWithURI:(NSString *)uri;
@end

/**
 A protocol to be implemented by Content Hub's parent
 view controller (assumes embedded mode), giving the
 Content Hub the ability to communicate back with its parent.
 */
@protocol ZBiMContentHubContainerDelegate <NSObject>
- (void) closeContentHub;
@optional
- (void) updateControls;
@end

@protocol ZBiMBackgroundDownloadsDelegate <NSObject>
- (void) scheduleBackgroundFetch:(NSTimeInterval)timeInterval;
- (void) cancelBackgroundFetch;
@end

/**
 A protocol allowing the client application to register a class as
 the provider of checking-for-new-content, download-in-progress and
 error-reporting views, thus overriding the default status reporting UI.
 */
@protocol ZBiMContentHubStatusUIDelegate <NSObject>
- (UIView *) getErrorView:(NSString *)optionalMessage;
- (UIView *) getCheckingForContentView:(NSString *)optionalMessage;
- (UIView *) getDownloadProgressView:(NSString *)optionalMessage percentCompleted:(CGFloat)percentCompleted;
@optional
- (UIImage *)getStatusCloseButtonImage;
@end

#pragma mark ZBiM

/**
 This class is the main entry point for managing aspects of the ZBI library.
 */
@interface ZBiM : NSObject

/**
 Initializes the ZBiM SDK.
 */
+ (void) start;

/**
 Returns the current logging severity level.
 */
+ (ZBiMSeverityLevel) severityLevel;

/**
 Returns the current logging verbosity level.
 */
+ (ZBiMVerbosityLevel) verbosityLevel;

/**
 Controls the logging severity level for the ZBI library.

 @param severityLevel Use one of the following values:

 ZBiMLogSeverityNone
 ZBiMLogSeverityCriticalError
 ZBiMLogSeverityError
 ZBiMLogSeverityWarning
 ZBiMLogSeverityInfo

 Defaults to ZBiMLogSeverityInfo for debug builds and ZBiMLogSeverityError for release builds.
 */
+ (void) setSeverityLevel:(ZBiMSeverityLevel)severityLevel;

/**
 Controls the logging verbosity level for the ZBiM SDK.

 @param verbosityLevel Use one of the following values:

 ZBiMLogVerbosityNone
 ZBiMLogVerbosityDebug
 ZBiMLogVerbosityInfo

 Defaults to ZBiMLogVerbosityDebug.
 */
+ (void) setVerbosityLevel:(ZBiMVerbosityLevel)verbosityLevel;

/**
 Helper method generating a default user ID. To be used in
 the case client application does not have the concept of
 one and does not care for the value itself.

 @return Default user ID.
 */
+ (NSString *) generateDefaultUserId;

/**
 Creates a new user and associates it with the set of tags.
 There can be multiple users per app instance, but only one can be
 set as the active user at any point in time. Before content hub
 can be shown an active user must be set (via setActiveUser method).

 @param userId A string identifying the user. It can be app-specific or a default one can be generated by ZBiM SDK (see generateDefaultUserId method).
 @param withTags A list of tags that describe the user's preferences. Used for content targeting. Can be nil or empty.
 @param error An error object to be populated in the event of failure to create user.

 @return YES if user successfully created, NO otherwise.
 */
+ (BOOL) createUser:(NSString *)userId withTags:(NSArray *)tags error:(NSError * __autoreleasing *)error;

/**
 Gets the list of all previously created users.

 @return Array of user IDs.
 */
+ (NSArray *) getAllUsers;

/**
 Get the current active user.

 @return ID for current active user.
 */
+ (NSString *) activeUser;

/**
 Sets current active user ID.

 @param userId A string identifying the user.
 @param error An error object to be populated in the event of failure to set active user.

 @return YES if user ID successfully set as current active user, NO otherwise.
 */
+ (BOOL) setActiveUser:(NSString *)userId error:(NSError * __autoreleasing *)error;

/**
 Provides access to list of tags associated with given user ID. Tags are sorted
 by usage count, with the highest one being at index 0.

 @param userId Identifier for user to retrieve tagging information for.
 @param error An error object to be populated in the event tagging data retrieval fails.

 @return An array of tags associated with given user ID.
 */
+ (NSArray *)tagsForUser:(NSString *)userId error:(NSError * __autoreleasing *)error;

/**
 Provides access to tags' usage counts for given user ID.

 @param userId Identifier for user to retrieve tagging information for.
 @param error An error object to be populated in the event tagging data retrieval fails.
 
 @return A dictionary of tag/usage count data, associated with given user ID.
 */
+ (NSDictionary *)tagUsageCountsForUser:(NSString *)userId error:(NSError * __autoreleasing *)error;

/**
 Allows host application to influence content tailoring by supplementing tagging
 data used by the SDK. With every call of the following method, the usage count
 of the tags is increased or decreased. If a tag's usage count drops to 0 or below
 it is deleted. The updated tags usage counts are associated with the current active user.
 
 @param tags A dictionary of tag/usage count data. The given usage count is added to the existing tag usage count.
 @param error An error object to be set in the event the method call fails.
 
 @return YES if the method call succeeded, NO otherwise.
 */
+ (BOOL)updateTagUsageCounts:(NSDictionary *)tags error:(NSError * __autoreleasing *)error;

/**
 A Content Hub entry point identifies the part of a client application that triggered
 presenting the Content Hub. The entry point should be set immediately before requesting
 a Content Hub to be presented. The value will be reset as soon as it has been used, so
 it does not affect subsequent attempts at presenting a Content Hub. The application needs
 to set the value explicitly every time it is needed.
 
 @param entryPoint A string value, meaningful to the client application, that identifies the portion of the code that triggered presenting the Content Hub. Used for metrics reporting.
 */
+ (void) setContentHubEntryPoint:(NSString *)entryPoint;

/**
 Displays the Content Hub UI in a modal view mode. The SDK decides what is the appropriate presenting view controller.
 If content bundle contains multiple hub pages the one that matches best the set of tags associated with current active user is selected and loaded.
 If tags are not used, the first available hub page is selected and loaded, based on an internal ordering scheme, as specified in the content bundle.
 
 @param completionCallback A block of code to be executed upon completion of the task. Block's parameters indicate the task's outcome.
 */
+ (void) presentHub:(void (^)(BOOL success, NSError *error))completionCallback;

/**
 Displays the Content Hub UI using the presenting view controller passed as a parameter.
 If content bundle contains multiple hub pages the one that matches best the set of tags associated with current active user is selected and loaded.
 If tags are not used, the first available hub page is selected and loaded, based on an internal ordering scheme, as specified in the content bundle.
 
 @param presentingViewController A view controller to be used to present the Content Hub.
 @param completionCallback A block of code to be executed upon completion of the task. Block's parameters indicate the task's outcome.
 */

+ (void) presentHubWithPresentingViewController:(UIViewController *)presentingViewController
                                     completion:(void (^)(BOOL success, NSError *error))completionCallback;

/**
 Displays the Content Hub UI inside the parent view passed as a parameter. 
 If content bundle contains multiple hub pages the one that matches best the set of tags associated with current active user is selected and loaded.
 If tags are not used, the first available hub page is selected and loaded, based on an internal ordering scheme, as specified in the content bundle.
 
 @param parentView A view that will have the content hub's view as a child. Content hub will use 100% of the parent view area.
 @param parentViewController A view controller for the parent view, which will have the content hub's view controller as a child view controller.
 @param completionCallback A block of code to be executed upon completion of the task. Block's parameters indicate the task's outcome.
 
 @return A content hub delegate which allows client app to interact with content hub via methods provided by the ZBiMContentHubDelegate protocol.
 */
+ (id<ZBiMContentHubDelegate>) presentHubWithParentView:(UIView *)parentView
                             parentViewController:(UIViewController *)parentViewController
                                       completion:(void (^)(BOOL success, NSError *error))completionCallback;

/**
 Displays the Content Hub UI in a modal view mode. The SDK decides what is the appropriate presenting view controller.
 If content bundle contains multiple hub pages, the one that matches best the set of tags passed as a parameter is selected and loaded.

 @param tags A set of tags to be used when selecting a hub page to load.
 @param completionCallback A block of code to be executed upon completion of the task. Block's parameters indicate the task's outcome.
 */
+ (void) presentHubWithTags:(NSArray *)tags completion:(void (^)(BOOL success, NSError *error))completionCallback;

/**
 Displays the Content Hub UI using the presenting view controller passed as a parameter.
 If content bundle contains multiple hub pages, the one that matches best the set of tags passed as a parameter is selected and loaded.
 
 @param presentingViewController A view controller to be used to present the Content Hub.
 @param tags A set of tags to be used when selecting a hub page to load.
 @param completionCallback A block of code to be executed upon completion of the task. Block's parameters indicate the task's outcome.
 */
+ (void) presentHubWithTags:(NSArray *)tags
   presentingViewController:(UIViewController *)presentingViewController
                 completion:(void (^)(BOOL success, NSError *error))completionCallback;

/**
 Displays the Content Hub UI inside the parent view passed as a parameter. 
 If content bundle contains multiple hub pages, the one that matches best the set of tags passed as a parameter is selected and loaded.

 @param parentView A view that will have the content hub's view as a child. Content hub will use 100% of the parent view area.
 @param parentViewController A view controller for the parent view, which will have the content hub's view controller as a child view controller.
 @param tags A set of tags to be used when selecting a hub page to load.
 @param completionCallback A block of code to be executed upon completion of the task. Block's parameters indicate the task's outcome.
 
 @return A content hub delegate which allows client app to interact with content hub via methods provided by the ZBiMContentHubDelegate protocol.
 */
+ (id<ZBiMContentHubDelegate>) presentHubWithTags:(NSArray *)tags
                                       parentView:(UIView *)parentView
                             parentViewController:(UIViewController *)parentViewController
                                       completion:(void (^)(BOOL success, NSError *error))completionCallback;

/**
 Displays the Content Hub UI in a modal view mode, loading a specific piece of content. The SDK decides what is the appropriate presenting view controller.
 
 @param uri A URI identifying the content to be loaded. URI can point to hub, channel or article.
 @param completionCallback A block of code to be executed upon completion of the task. Block's parameters indicate the task's outcome.
 */
+ (void) presentHubWithUri:(NSString *)uri completion:(void (^)(BOOL success, NSError *error))completionCallback;

/**
 Displays the Content Hub UI using the presenting view controller passed as a parameter, loading a specific piece of content.
 
 @param presentingViewController A view controller to be used to present the Content Hub.
 @param uri A URI identifying the content to be loaded. URI can point to hub, channel or article.
 @param completionCallback A block of code to be executed upon completion of the task. Block's parameters indicate the task's outcome.
 */
+ (void) presentHubWithUri:(NSString *)uri
  presentingViewController:(UIViewController *)presentingViewController
                completion:(void (^)(BOOL success, NSError *error))completionCallback;

/**
 Displays the Content Hub UI inside the parent view passed as a parameter, loading a specific piece of content.
 
 @param parentView A view that will have the content hub's view as a child. Content hub will use 100% of the parent view area.
 @param parentViewController A view controller for the parent view, which will have the content hub's view controller as a child view controller.
 @param uri A URI identifying the content to be loaded. URI can point to hub, channel or article.
 @param completionCallback A block of code to be executed upon completion of the task. Block's parameters indicate the task's outcome.
 
 @return A content hub delegate which allows client app to interact with content hub via methods provided by the ZBiMContentHubDelegate protocol.
 */
+ (id<ZBiMContentHubDelegate>) presentHubWithUri:(NSString *)uri
                                      parentView:(UIView *)parentView
                            parentViewController:(UIViewController *)parentViewController
                                      completion:(void (^)(BOOL success, NSError *error))completionCallback;

/**
 Displays a previously presented content hub, e.g. one that was
 presented, dismissed and kept around to preserve user's state.
 
 @param existingContentHub The previously presented content hub that's to be displayed.
 @param completionCallback A block of code to be executed upon completion of the task. Block's parameters indicate the task's outcome.
 */
+ (void) presentExistingContentHub:(id<ZBiMContentHubDelegate>)existingContentHub
                        completion:(void (^)(BOOL success, NSError *error))completionCallback;

/**
 Sets the advertiser ID delegate, which allows client application to determine
 what it considers to be a relevant advertiser ID value.
 */
+ (void)setAdvertiserIdDelegate:(id<ZBiMAdvertiserIdDelegate>)advertiserIdDelegate;

/**
 Sets the location service delegate, which allows client application provide
 location information to the SDK */
+ (void)setLocationServiceDelegate:(id<ZBiMLocationServiceDelegate>)locationServiceDelegate;

/**
 Sets the logging delegate, which allows client application to determine what
 logging data to process and how, based on the associated logging severity
 and verbosity levels.
 */
+ (void)setLoggingDelegate:(id<ZBiMLoggingDelegate>)loggingDelegate;

/**
 Allows a class implementing the ZBiMBackgroundDownloadsDelegate protocol
 to set itself as the corresponding delegate for handling scheduling
 of background fetching of data. If not set, ZBiM SDK will have full
 control over setting and resetting background fetch intervals by calling
 setMinimumBackgroundFetchInterval. Otherwise ZBiM SDK will delegate
 this task to the object passed as parameter.
 */
+ (void)setBackgroundDownloadsDelegate:(id<ZBiMBackgroundDownloadsDelegate>)backgroundDownloadsDelegate;

/**
 Returns a boolean value indicating whether the ZBi brand logo
 is to be displayed by any of the ZBi SDK-owned UI containers,
 e.g. lower-right corner of the built-in web view container.
 By default this flag is set to YES.
 */
+ (BOOL) showZBILogo;

/**
 Controls the visibility of the ZBi brand logo throughout the
 ZBi SDK-owned UI containers.
 */
+ (void) setShowZBILogo:(BOOL)showZBILogo;

/**
 Indicates if ZBiM SDK is currently downloading content
 to be displayed inside content hub.

 @return YES if content is currently being downloaded, NO otherwise.
 */
+ (BOOL) isDownloadingContent;

/**
 Indicates if content hub is currently being displayed.

 @return YES if content hub is currently being displayed (even if it may not be currently visible), NO otherwise.
 */
+ (BOOL) isDisplayingContentHub;

/**
 @return Content Hub that is currently being displayed (even if it may not be currently visible), Nil otherwise.
 */
+ (id<ZBiMContentHubDelegate>) getCurrentContentHub;

/**
 Indicates that content has been successfully downloaded and
 content hub is ready to be displayed and serve it.

 @return YES if content hub is ready to serve content, NO otherwise.
 */
+ (BOOL) isReady;

/**
 Indicates if ZBiM SDK has entered lockdown or not. Once it has,
 it will stop responding to any requests from the client app and
 there should be no attempts to interact with ZBiM SDK.
 It will take a client app update to get ZBiM SDK back to a
 functional state.
 */
+ (BOOL) isDisabled;

/**
 Indicates whether ZBiM SDK is not part of a pilot program,
 either because it was not allowed to joint or because it
 lost its membership as part of a pilot program update.
 The property is set to YES only when access to a pilot program
 has been denied. If ZBiM SDK is part of an existing pilot 
 program or there's no pilot program, then it's set to NO.
 */
+ (BOOL) notPartOfPilotProgram;

/**
 Gets the value of the initial content download mode, which specifies
 whether to download new content immediately upon SDK being initialized 
 or to wait until the user expresses explicit interest in consuming content.
 The latter, i.e. on-demand, is the default. This property is applicable
 only when there's no previously downloaded content, hence "initial".
 There is no programmatic way to set this value. Changing it can only
 be done via the ZBiM portal and passed through to the SDK via the
 content bundle itself.
 */
+ (ZBiMInitialContentDownloadMode) initialContentDownloadMode;

/**
 Gets the value of the content refresh mode, which specifies
 how content is to be updated after the initial download completes
 successfully. The default is to show previously downloaded content
 and kick off an asynchronous refresh. There is no programmatic way 
 to set this value. Changing it can only be done via the ZBiM portal 
 and passed through to the SDK via the content bundle itself.
 */
+ (ZBiMContentRefreshMode) contentRefreshMode;

/**
 Gets the time interval between content refreshes. Applicable only when
 content refresh mode has a value of ZBiMContentRefreshModeRecurring.
 There is no programmatic way to set this value. Changing it can only 
 be done via the ZBiM portal and passed through to the SDK via the 
 content bundle itself.
 */
+ (NSTimeInterval) contentRefreshInterval;

/**
 Gets the value of the content hub's color scheme.

 Currently only two color schemes are supported (dark and light), the former
 being the default.

 @return Current color scheme for content hub UI.
 */
+ (ZBiMColorScheme) colorScheme;
/**
 Sets the color scheme for content hub. If content hub has already been loaded,
 it will not be affected by changes to the color scheme (but next content hub
 loaded will be).
 */
+ (void) setColorScheme:(ZBiMColorScheme)colorScheme;

/**
 Gets the Content Hub's content source. 
 
 @return See description of setContentSource:'s contentSource parameter
 for details on the possible values and their meaning.
 */
+ (ZBiMContentSource) contentSource;

/**
 Sets the Content Hub's content source. 
 
 @param contentSource When the value of contentSource is ZBiMContentSourceLocalOnly,
 then all content must have been previously downloaded and available locally.
 All network requests having a URL that's not part of DB will be declined.
 If contentSource is ZBiMContentSourceExternalAllowed, then external content
 will be allowed, e.g. and embedded image or video hosted remotely. Resources
 representing a container for one of the three main resource types, i.e. hub,
 channel and article must still come from local DB, regardless of content source value.
 */
+ (void) setContentSource:(ZBiMContentSource)contentSource;

/**
 Gives the ZBiM SDK the option to confirm if it can handle a local notification. If the SDK
 does not recognize the format, e.g. it's a local notification scheduled
 outside of the SDK, it will inform the application (via return value)
 that it can handle the local notification itself.

 @return YES if this is a ZBiM local notification that can be handled, NO otherwise.
 */
+ (BOOL) canHandleLocalNotification:(UILocalNotification *)notification;

/**
 Gives the ZBiM SDK the option to handle a local notification. If the SDK
 does not recognize the format, e.g. it's a local notification scheduled
 outside of the SDK, it will inform the application (via return value)
 that it should handle the local notification itself.

 Assumes that the user has not expressed any intention to view corresponding
 content and will first show an UIAlertView prompting the user to OK. Upon
 user requesting to proceed with notification target action, a Content Hub
 will be presented (if there isn't one already) and the content pointed to
 by URI that's part of local notification's metadata will be loaded.

 @return YES if this is a ZBiM local notification that can be handled, NO otherwise.
 */
+ (BOOL) handleLocalNotification:(UILocalNotification *)notification;

/**
 Gives the ZBiM SDK the option to handle a local notification. If the SDK
 does not recognize the format, e.g. it's a local notification scheduled
 outside of the SDK, it will inform the application (via return value)
 that it should handle the local notification itself.

 Assumes that the user has already expressed an intention to view corresponding
 content and will go straight to presenting a Content Hub (if there isn't one
 already) and the content pointed to by URI that's part of local notification's
 metadata will be loaded.

 @return YES if this is a ZBiM local notification that can be handled, NO otherwise.
 */
+ (BOOL) handleLocalNotification:(UILocalNotification *)notification showAlert:(BOOL)showAlert;

/**
 Allows instructing ZBiM SDK which URLs should be exempt from its security
 restrictions (enforced when user is interacting with the Content Hub).

  @param url URL to be exempt from ZBiM SDK's security restrictions.
 */
+ (void) whitelistURL:(NSURL *)url;

/**
 Allows instructing ZBiM SDK which domain names should be exempt from its security
 restrictions (enforced when user is interacting with the Content Hub).
 Similar to whitelistURL, but less granular.
 
 @param domainName Domain name to be exempt from ZBiM SDK's security restrictions. E.g. www.zumobi.com
 */
+ (void) whitelistDomainName:(NSString *)domainName;

/**
 Allows ZBiM SDK to distinguish custom URL schemes handled by the host
 application and provide special pass-through treatment.
 
 @param customURLScheme Scheme to be treated as requiring a pass-through.
 */
+ (void) registerCustomURLScheme:(NSString *)customURLScheme;

/**
 Determines if an URLSession is related to ZBiM SDK or not. To be used to disambiguate
 who needs to handle events for a background session (host application or ZBiM SDK) 
 in case application uses a background session itself.
 */
+ (BOOL)canHandleEventsForBackgroundURLSession:(NSString *)identifier;

/**
 Sets the completion handler for a background session to be called by ZBiM SDK
 when all related task have been complete. Assumes application has already
 called canHandleEventsForBackgroundURLSession: to confirm background session
 belongs to ZBiM SDK. Method is intended to be called host application inside 
 UIApplication's handleEventsForBackgroundURLSession:completionHandler: method.
 */
+ (void)setBackgroundSessionCompletionHandler:(void (^)())completionHandler;

/**
 Gives ZBiM SDK turn to perform a background fetch, allowing it to retrieve
 content data while host application is in background. Host application has the
 option to pass along the actual completionHandler, provided to it by UIApplication's
 performFetchWithCompletionHandler method. That's assuming application has no
 other work to do as part of this background fetch slot. Alternatively it can pass
 a block which takes UIBackgroundFetchResult as a parameter in case it needs
 to do combined reporting of background fetch completion.
 */
+ (void)performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

/**
 By default, ZBiM SDK reads public key from a file named pubkey.der, which
 it expects to fund in the app's main bundle. If you need to change that
 behavior, the following method allows overriding the path to the file and
 will instruct the ZBiM SDK to use it instead.
 Must be called before ZBiM's start method, otherwise the value will be ignored.
 Must be called every time the ZBiM SDK is about to be initialized, as the
 override is not going to persist across mutiple SDK sessions.
 */
+ (void)setPathToPublicKey:(NSString *)fullPath;

/**
 By default, ZBiM SDK reads its config from a file named zbimconfig.plist, which
 it expects to fund in the app's main bundle. If you need to change that
 behavior, the following method allows overriding the path to the file and
 will instruct the ZBiM SDK to use it instead.
 Must be called before ZBiM's start method, otherwise the value will be ignored.
 Must be called every time the ZBiM SDK is about to be initialized, as the
 override is not going to persist across mutiple SDK sessions.
 */
+ (void)setPathToConfig:(NSString *)fullPath;

/**
 Allows the client application to customize the checking-for-new-content, 
 download-in-progress and error-reporting UIs (part of Content Hub) by 
 registering a class to be the provider for these status reporting views.
 */
+ (void) setCustomStatusUIDelegate:(id<ZBiMContentHubStatusUIDelegate>)delegate;

#pragma mark ZBiM Widget

/**
 Gets a list of ZBiM widgets, matching the criteria specified by the method parameters.
 
 @param resourceType Determines the type of content to get widgets for. Supported values are ZBiMResourceTypeHub, ZBiMResourceTypeChannel or ZBiMResourceTypeArticle.
 @param maxCount Limits the number of widgets to return. 0 stands for unlimited.
 @param tags Tags to use for content tailoring, i.e. sorting widgets. If tags is not defined, SDK will use any tags associated with current active user.
 @param contentTailoringEnabled Determines if content tailoring should be performed or not (i.e. it is not enough to pass nil for tags).
 @param callback Block of code to call upon completion, passing back a list of widgets (or an error).
 */
+ (void) getWidgetsWithResourceType:(NSString *)resourceType
                           maxCount:(NSUInteger)maxCount
                               tags:(NSArray *)tags
            contentTailoringEnabled:(BOOL)contentTailoringEnabled
                           callback:(void (^)(NSArray *widgets, NSError *error))callback;
/**
 Helper method to allow adding a ZBiM widget to a container view, e.g. a UITableViewCell.
 */
+ (void) addWidget:(ZBiMWidget *)widget containerView:(UIView *)containerView containerViewController:(UIViewController *)containerViewController;

/**
 Helper method to allow removing a ZBiM widget from a container view, e.g. a UITableViewCell that's being reused.
 */
+ (void) removeWidget:(ZBiMWidget *)widget containerView:(UIView *)containerView;

@end


/**
 A protocol to be implemented by a class that a ZBiM widget
 can delegate tasks to, e.g. presenting an embedded Content Hub
 on behalf of a widget.
 */
@protocol ZBiMWidgetDelegate <NSObject>
- (void)presentContentHubWithURI:(NSString *)uri;
@end


/**
 A widget represents an entry point to a piece of content (typically an 
 article, but it can also point to a hub or a channel). A widget sizes 
 itself to the space provided by the host application and is generally 
 intended to be much smaller than a Content Hub, hence it is an entry
 point to a piece of content and not the content itself.
 */
@interface ZBiMWidget : UIViewController

/**
 An object that a ZBiM widget can delegate tasks to,
 e.g. presenting an embedded Content Hub on behalf of a widget.
 */
@property (nonatomic, weak) id<ZBiMWidgetDelegate>delegate;

/**
 Performs the default action associated with a widget, e.g.
 presenting a Content Hub.
 */
- (void) performAction;
@end
