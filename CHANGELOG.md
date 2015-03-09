# ZBiM SDK CHANGELOG

## 1.1.4

### New Feeatures
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