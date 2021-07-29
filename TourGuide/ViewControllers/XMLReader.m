//
//  XMLReader.m
//
//  Created by Troy Brant on 9/18/10.
//  Updated by Antoine Marcadet on 9/23/11.
//  Updated by Divan Visagie on 2012-08-26
//  Updated by Kui Liu on 2014/10/31
//

#import "XMLReader.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "XMLReader requires ARC support."
#endif

NSString *const kXMLReaderTextNodeKey		= @"jacknode";
NSString *const kXMLReaderAttributePrefix	= @"@";

@interface XMLReader ()

@property (nonatomic, strong) NSMutableArray *dictionaryStack;
@property (nonatomic, strong) NSMutableString *textInProgress;
@property (nonatomic, strong) NSError *errorPointer;

@end


@implementation XMLReader

#pragma mark - Public methods

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error
{
    XMLReader *reader = [[XMLReader alloc] initWithError:error];
    NSDictionary *rootDictionary = [reader objectWithData:data options:0];
    return rootDictionary;
}

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)error
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [XMLReader dictionaryForXMLData:data error:error];
}


#pragma mark -
+(NSMutableDictionary *)recursionRemoveTextNode:(NSDictionary *)dic
{
    NSMutableDictionary *dic_ = [NSMutableDictionary dictionary];
    for(id key in dic)
    {
//        NSLog(@"print out class %@",[[dic objectForKey:key] class]);
        
        if([[[dic objectForKey:key] class] isSubclassOfClass:[NSDictionary class]])
        {
            //if it is nsdictionary , then we go deep to see the first key of this dicitonary
            if([[dic objectForKey:key] count]==1)
            {
                NSMutableDictionary *tempDic = [dic objectForKey:key];
                for(id key_ in tempDic)
                {
                    NSString *string_key = [NSString stringWithFormat:@"%@",key_];
                    if([string_key isEqualToString:kXMLReaderTextNodeKey])
                    {
                        [dic_ setObject:[tempDic objectForKey:key_] forKey:key];//remove message key
                    }
                    else
                        [dic_ setObject:[self recursionRemoveTextNode:[dic objectForKey:key]] forKey:key];
                }
            }
            else
                [dic_ setObject:[self recursionRemoveTextNode:[dic objectForKey:key]] forKey:key];
        }
        else if([[[dic objectForKey:key] class] isSubclassOfClass:[NSArray class]])
        {
            NSMutableArray *newArray = [NSMutableArray array];
            NSMutableArray *array = [[dic objectForKey:key] mutableCopy];
            
            for(int i =0 ; i < [array count]; i++)
            {
                NSMutableDictionary *tempDic = [self recursionRemoveTextNode:[array objectAtIndex:i]];
                [newArray addObject:tempDic];
            }
            
            [dic_ setObject:newArray forKey:key];
        }
        else
        {
            [dic_ setObject:[dic objectForKey:key] forKey:key];
        }
    }
    return dic_;
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data options:(XMLReaderOptions)options
{
    NSError *err = [NSError errorWithDomain:@"some_domain"
                                       code:100
                                   userInfo:@{
                                              NSLocalizedDescriptionKey:@"Something went wrong"
                                              }];
    
    XMLReader *reader = [[XMLReader alloc] initWithError:&err];
    NSDictionary *rootDictionary = [reader objectWithData:data options:options];
    return rootDictionary;
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data options:(XMLReaderOptions)options error:(NSError **)error
{
    XMLReader *reader = [[XMLReader alloc] initWithError:error];
    NSDictionary *rootDictionary = [reader objectWithData:data options:options];
    return rootDictionary;
}

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string options:(XMLReaderOptions)options error:(NSError **)error
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [XMLReader dictionaryForXMLData:data options:options error:error];
}

+ (NSDictionary*)returnDictionary:(NSDictionary*)dict
{
    NSMutableDictionary * result = [NSMutableDictionary new];
    
    for(NSDictionary * key in dict[@"plist"][@"dict"][@"key"])
    {
        result[key[@"jacknode"]] = dict[@"plist"][@"dict"][@"string"][[dict[@"plist"][@"dict"][@"key"] indexOfObject:key]][@"jacknode"];
    }
    
    return result;
}


#pragma mark - Parsing

- (id)initWithError:(NSError **)error
{
	self = [super init];
    if (self)
    {
        self.errorPointer = *error;
    }
    return self;
}

- (NSDictionary *)objectWithData:(NSData *)data options:(XMLReaderOptions)options
{
    // Clear out any old data
    self.dictionaryStack = [[NSMutableArray alloc] init];
    self.textInProgress = [[NSMutableString alloc] init];
    
    // Initialize the stack with a fresh dictionary
    [self.dictionaryStack addObject:[NSMutableDictionary dictionary]];
    
    // Parse the XML
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    
    [parser setShouldProcessNamespaces:(options & XMLReaderOptionsProcessNamespaces)];
    [parser setShouldReportNamespacePrefixes:(options & XMLReaderOptionsReportNamespacePrefixes)];
    [parser setShouldResolveExternalEntities:(options & XMLReaderOptionsResolveExternalEntities)];
    
    parser.delegate = self;
    BOOL success = [parser parse];
	
    // Return the stack's root dictionary on success
    if (success)
    {
        NSDictionary *resultDict = [self.dictionaryStack objectAtIndex:0];
        return resultDict;
    }
    
    return nil;
}


#pragma mark -  NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{   
    // Get the dictionary for the current level in the stack
    NSMutableDictionary *parentDict = [self.dictionaryStack lastObject];

    // Create the child dictionary for the new element, and initilaize it with the attributes
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];
    
    // If there's already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue)
    {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]])
        {
            // The array exists, so use it
            array = (NSMutableArray *) existingValue;
        }
        else
        {
            // Create an array if it doesn't exist
            array = [NSMutableArray array];
            [array addObject:existingValue];

            // Replace the child dictionary with an array of children dictionaries
            [parentDict setObject:array forKey:elementName];
        }
        
        // Add the new child dictionary to the array
        [array addObject:childDict];
    }
    else
    {
        // No existing value, so update the dictionary
        [parentDict setObject:childDict forKey:elementName];
    }
    
    // Update the stack
    [self.dictionaryStack addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // Update the parent dict with text info
    NSMutableDictionary *dictInProgress = [self.dictionaryStack lastObject];
    
    // Set the text property
    if ([self.textInProgress length] > 0)
    {
        // trim after concatenating
        NSString *trimmedString = [self.textInProgress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [dictInProgress setObject:[trimmedString mutableCopy] forKey:kXMLReaderTextNodeKey];

        // Reset the text
        self.textInProgress = [[NSMutableString alloc] init];
    }
    
    // Pop the current dict
    [self.dictionaryStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // Build the text value
    [self.textInProgress appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    // Set the error pointer to the parser's error object
    self.errorPointer = parseError;
}

@end
