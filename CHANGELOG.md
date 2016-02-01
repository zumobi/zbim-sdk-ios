# ZBiM SDK CHANGELOG

## 1.2

### New Features
* Optimizations around content downloading. Adds support for different initial download and subsequent refresh modes.
* Pilot program support, enabling only a subset of all users to be enrolled. Controllable remotely (via portal page).
* New APIs allowing host application read/write access to user's tag profile. 
* Adds support for updating SDK config and public key during runtime. Useful for remote reconfiguration without rebuilding application.
* Ability to annotate different Content Hub entry points for the purpose of metrics reporting.

### Resolved Issues
* Performance and stability improvements.

## 1.1.11

### Resolved Issues
* Minor fix related to metrics reporting. 

## 1.1.10

### New Features
* Application can register itself as the provider for status reporting views, e.g. checking-for-new-content, download-in-progress, error-encountered, thus overriding the default UI.
* Application can include pre-cached content, which allows for a zero-delay user experience when showing Content Hub. 

### Resolved Issues
* Status reporting UI was getting stuck on checking-for-new-content stage, unable to update status reporting UI to reflect download-in-progress.

## 1.1.9

### Resolved Issues
* Presenting a new Content Hub can fail if done immediately after previous one has been dismissed, e.g. in the same iteration of the run loop. 

## 1.1.8

### New Features
* Added support for an embedded Content Hub to delegate commands to parent view controller.

## 1.1.7

### New Features
* Allow host application to present Content Hub with a specific URI.
* Allow host application to pass presenting view controller as an argument.

## 1.1.6

### New Features
* Added throttling for forward and backward navigation requests inside Content Hub to avoid unwanted side effects when multiple requests are issued in close succession.

## 1.1.5

### Resolved Issues
* Content Hub can get stuck loading certain assets if device is connected to network, but experiencing 100% packet loss.
* Channel items not sorted by publishing date.
* YouTube videos have links allowing users to navigate to unrelated YouTube content inside Content Hub.
* Content-changed notification not firing consistently due to cache interference.

## 1.1.4

### New Features
* Enabled a host application to configure the Content Hub's background color.

### Resolved Issues
* YouTube video interfering with content being loaded asynchronously while Content Hub is in the background.
* Download progress reporting can be slightly off when dealing with compressed content.

## 1.1.3

### New Features
* Expanded list of properties reported with ZBiMContentTypeChanged notification to include title and URL.
* Added support for whitelisting domains.
* Added new mode for controlling source of data, allowing Content Hub to access resources outside of content bundle, unless overridden by application.

### Resolved Issues
* Additional logging and error checking around presenting a Content Hub.
* Improved handling of custom URL schemes.
