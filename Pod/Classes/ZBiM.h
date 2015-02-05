//
//  ZBiM.h
//
//  ZBiM SDK Library
//
//  Copyright (c) 2014, Zumobi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
#error ZBiM SDK requires min deployment target of iOS 7.0 or higher
#endif

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

#define ZBIM_ERROR_DOMAIN @"com.Zumobi.ZBiM.ErrorDomain"

typedef enum : NSUInteger
{
    ZBiMErrorNone = 0,
    ZBiMErrorInvalidParams,
    ZBiMErrorInvalidState,
    ZBiMErrorNoNetwork,
    ZBiMErrorUnknownUser,
    ZBiMErrorUserAlreadyExists,
    ZBiMErrorActiveUserNotSet,
    ZBiMErrorOperationAlreadyInProgress,
    ZBiMErrorMissingDB,
    ZBiMErrorMissingContent,
    ZBiMErrorSDKDisabledState
} ZBiMError;

# pragma mark Content Hub sync modes

typedef enum : NSUInteger
{
    ZBiMSyncNonBlocking = 0,
    ZBiMSyncBlocking
} ZBiMSyncMode;

#pragma mark Content Hub color schemes

typedef enum : NSUInteger
{
    ZBiMColorSchemeDark = 0,
    ZBiMColorSchemeLight
} ZBiMColorScheme;

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
 Notification indicating that the type of content being shown
 has changed.
 */
extern NSString *const ZBiMContentTypeChanged;

#pragma mark Content Hub content type

// Key and values in the ZBiMContentTypeChanged notification's userInfo dictionary,
// used to communicate the latest type of content loaded in the Content Hub.
extern NSString *const ZBiMResourceType;        // key
extern NSString *const ZBiMResourceTypeHub;     // value ("hub")
extern NSString *const ZBiMResourceTypeChannel; // value ("channel")
extern NSString *const ZBiMResourceTypeArticle; // value ("article")

#pragma mark ZBiM protocols

/**
 Allows client application to determine what it considers to
 be a relevant value for advertiser ID.
 */
@protocol ZBiMAdvertiserIdDelegate <NSObject>
- (NSString *)advertiserId;
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
 Provides access to tagging data associated with given user ID.

 @param userId Identifier for user to retrieve tagging information for.
 @param error An error object to be populated in the event tagging data retrieval fails.

 @return An array of tags associated with given user ID.
 */
+ (NSArray *)tagsForUser:(NSString *)userId error:(NSError * __autoreleasing *)error;

/**
 Displays the content hub in modal view mode.

 @param tags A set of tags to be used to override the ones associated with the current active user. Can be nil.
 @param completionCallback A block of code to be executed upon completion of the task. Block's parameters indicate the task's outcome.
 */
+ (void) presentHubWithTags:(NSArray *)tags completion:(void (^)(BOOL success, NSError *error))completionCallback;

/**
 Displays the content hub inside the parent view passed as parameter.

 @param parentView A view that will have the content hub's view as a child. Content hub will use 100% of the parent view area.
 @param parentViewController A view controller for the parent view, which will have the content hub's view controller as a child view controller.
 @param tags A set of tags to be used to override the ones associated with the current active user. Can be nil.
 @param completionCallback A block of code to be executed upon completion of the task. Block's parameters indicate the task's outcome.
 
 @return A content hub delegate which allows client app
         to interact with content hub via methods provided
         by the ZBiMContentHubDelegate protocol.
 */
+ (id<ZBiMContentHubDelegate>) presentHubWithTags:(NSArray *)tags
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
 Allows client app to request updating the hub content's source.
 Typically that's done automatically by the ZBiM SDK itself, but the
 client app has to option to request this explicitly if it needs to.
 */
+ (void) refreshContentSource;

/**
 Sets the advertiser ID delegate, which allows client application to determine
 what it considers to be a relevant advertiser ID value.
 */
+ (void)setAdvertiserIdDelegate:(id<ZBiMAdvertiserIdDelegate>)advertiserIdDelegate;

/**
 Sets the logging delegate, which allows client application to determine what
 logging data to process and how, based on the associated logging severity
 and verbosity levels.
 */
+ (void)setLoggingDelegate:(id<ZBiMLoggingDelegate>)loggingDelegate;

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
 Returns the value for sync mode. Sync refers to downloading the content
 bundle and instructs the SDK when and how to perform the task. By default
 sync mode is ZBiMSyncNonBlocking, which leaves it to the SDK to make such
 decisions on behalf of app. The alternative is ZBiMSyncBlocking, which
 requires the content bundle freshness verified before content hub can be
 displayed. If there's newer content to be downloaded, the SDK will make
 the content hub to wait, showing a progress bar indicator, for the download
 to complete.
 */
+ (ZBiMSyncMode) syncMode;

/**
 Allows setting of the above-mentioned property.
 */
+ (void) setSyncMode:(ZBiMSyncMode)syncMode;

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
 Allows instructing ZBiM SDK which URL schemes should be exempt from its security
 restrictions (enforced when user is interacting with the Content Hub).

 @param urlScheme Scheme to be exempt from ZBiM SDK's security restrictions.
 */
+ (void) whitelistURLScheme:(NSString *)urlScheme;

@end
