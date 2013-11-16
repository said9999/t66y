#import "BackupContactsManager.h"
#import "XMLWriter.h"
#import "AccountManager.h"
#import "HTTPClient.h"
#import "AFNetworking.h"
#import <AddressBook/AddressBook.h>
@implementation BackupContactsManager
+(id)sharedInstance{
    static BackupContactsManager *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(NSString *)backupContacts{
    NSLog(@"BackupContactsController backupContacts");
	// allocate serializer
	CFErrorRef error = NULL;
    
    XMLWriter* xmlWriter = [[XMLWriter alloc]init];
	[xmlWriter writeStartElement:@"backup"];
	[xmlWriter writeStartElement:@"regID"];
	[xmlWriter writeCharacters:[[AccountManager sharedAccountManager] str_RegID]];
	[xmlWriter writeEndElement];
	[xmlWriter writeStartElement:@"email"];
	[xmlWriter writeCharacters:[[AccountManager sharedAccountManager] str_Email]];
	[xmlWriter writeEndElement];
	[xmlWriter writeStartElement:@"action"];
	[xmlWriter writeCharacters:@"okBackUpContact"];
	[xmlWriter writeEndElement];
	[xmlWriter writeStartElement:@"typePhone"];
	[xmlWriter writeCharacters:@"iOS"];
	[xmlWriter writeEndElement];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
	__block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL)
    {
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
        {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                     {
                                                         accessGranted = granted;
                                                         dispatch_semaphore_signal(sema);
                                                     });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
        else if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
        {
            accessGranted = YES;
        }
        else if (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusDenied)
        {
            accessGranted = NO;
        }
        else if (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusRestricted){
            accessGranted = NO;
        }
        else
        {
            accessGranted = YES;
        }
    }
    else
    {
        accessGranted = YES;
    }
    if (accessGranted)
    {
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        DLog(@"No. of contacts %@",allContacts);
        for (int i = 0; i < [allContacts count]; i++)
        {
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
			ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
			NSString *phoneNumber = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumberProperty, 0);
            
            
                [xmlWriter writeStartElement:@"contact"];
				// start writing XML elements
				[xmlWriter writeStartElement:@"contact_name"];
				[xmlWriter writeCharacters:fullName];
				[xmlWriter writeEndElement];
			
				// start writing XML elements
				[xmlWriter writeStartElement:@"contact_number"];
				[xmlWriter writeCharacters:phoneNumber];
				[xmlWriter writeEndElement];
			
                [xmlWriter writeEndElement];
            CFRelease(phoneNumberProperty);

		}
	}
	[xmlWriter writeEndElement];
    CFRelease(addressBook);

	// get the resulting XML string
	NSString* xml = [xmlWriter toString];
	return xml;
}

-(void)sendContactsToServer
{
  /*  NSLog(@"BackupContactsController sendContactsToServer");
    
    NSString *xmlString = [self backupContacts];
    
    #warning must put paramters as NSDictionary for HTTPClient. Victor set it this way
     NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"okBackUpContact",@"action",@"iOS",@"typePhone",[[AccountManager sharedAccountManager]str_RegID],@"regID",xmlString,@"contact",[[AccountManager sharedAccountManager]str_Email],@"email",nil];
     
     NSLog(@"Sending backup: %@",userInfo);
     
    [[HTTPClient sharedHTTPClient] queryServerPath:@"phoneUpload.php" parameters:userInfo success:^(id jsonObject) {
        NSLog(@"Backup sent");
        //Server does not reply success or fail message
	} failure:^(NSError *error) {
        NSLog(@"Backup did not send");
    }];*/
   
    NSLog(@"BackupContactsController sendContactsToServer");
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SERVER_ADDRESS]];
	[httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
	
    NSString *xmlString = [self backupContacts];
    
	
	//AccountManager *manager = [AccountManager sharedAccountManager];
	//NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:@"okBackUpContact",@"action",[manager getEmail],@"email",@"iOS",@"typePhone",[manager getRegId],@"regID", nil];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"development/sites/all/modules/tracking/communication/phoneUpload.php" parameters:nil];
    [request setHTTPBody:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    //[request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	DLog(@"Sending :%@",xmlString);
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"okBackUpContact",@"action",@"iOS",@"typePhone",[[AccountManager sharedAccountManager]str_RegID],@"regID",[[AccountManager sharedAccountManager]str_Email],@"email",nil];
    request = [httpClient requestWithMethod:@"POST" path:@"development/sites/all/modules/tracking/communication/phoneDataReceive.php" parameters:userInfo];

	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		DLog(@"Received response: %@", JSON);
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
		DLog(@"Failed to backup !%@",[error localizedDescription]);
	}];
	[operation start];
	[operation waitUntilFinished];

}

@end
