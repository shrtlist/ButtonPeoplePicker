## Features
Button-style contact picker to select multiple people from the iPhone Address Book, with type-ahead and auto-completion.

### ButtonPeoplePicker.{h,m}
A custom view controller that encapsulates the contact picker functionality. This is the only class you need to interact with. Presented modally in this demo.

### AddPersonViewController.{h,m}
A custom view controller presented modally when there is no matching person in the Address Book. The new contact will be added to the Address Book.

Included is an iPhone Xcode storyboard project showing how to include a ButtonPeoplePicker in your own applications.
  
## Build Requirements
Xcode 4.2, iOS 5.0 SDK, LLVM Compiler 3.0, Automated Reference Counting (ARC).

## Runtime Requirements
iOS 5.0 and later.
 
## Screenshots

![](https://github.com/mabundo/ButtonPeoplePicker/raw/master/Screenshots/AddPeople.png)

![](https://github.com/mabundo/ButtonPeoplePicker/raw/master/Screenshots/SelectForDelete.png)

![](https://github.com/mabundo/ButtonPeoplePicker/raw/master/Screenshots/AddEmail.png)

![](https://github.com/mabundo/ButtonPeoplePicker/raw/master/Screenshots/AddPerson.png)

## License
The source code is available under the Apache License, Version 2.0
