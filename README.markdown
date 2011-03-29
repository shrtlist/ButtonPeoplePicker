# ButtonPeoplePicker

## Features
An iPhone UI contact picker to select multiple people from the Address Book, with type-ahead and auto-completion.

ButtonPeoplePicker.h/ButtonPeoplePicker.m
The UIViewController subclass that encapsulates the contact picker functionality. This is the only class you need to interact with.

AddPersonViewController.h/AddPersonViewController.m
A UIViewController displayed when there is no matching person in the Address Book. The new contact will be added to the Address Book.

All other files
A sample iPhone application showing how to include a ButtonPeoplePicker in your own applications.

## Requirements

* iOS SDK 4.2 or later.
* Project file (.xcodeproj):

  1. Base SDK (SDKROOT) should be "Latest iOS"
  2. Deployment Target (IPHONEOS_DEPLOYMENT_TARGET) can be "iOS 3.2" if you want.
 
## Screenshots

![](https://github.com/mabundo/ButtonPeoplePicker/raw/master/Screenshots/AddPeople.png)

![](https://github.com/mabundo/ButtonPeoplePicker/raw/master/Screenshots/SelectForDelete.png)

![](https://github.com/mabundo/ButtonPeoplePicker/raw/master/Screenshots/AddEmail.png)

![](https://github.com/mabundo/ButtonPeoplePicker/raw/master/Screenshots/AddPerson.png)

## License
The source code is available under the Apache License, Version 2.0
