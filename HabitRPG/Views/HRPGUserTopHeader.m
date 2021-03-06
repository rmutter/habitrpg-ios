//
//  HRPGUserTopHeader.m
//  Habitica
//
//  Created by viirus on 12.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGUserTopHeader.h"
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"
#import "User.h"
#import <PDKeychainBindings.h>
#import "HRPGLabeledProgressBar.h"
#import "HRPGGoldView.h"
#import "HRPGGemView.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

@interface HRPGUserTopHeader ()

@property UIImageView *avatarImageView;

@property HRPGLabeledProgressBar *healthLabel;

@property HRPGLabeledProgressBar *experienceLabel;

@property HRPGLabeledProgressBar *magicLabel;

@property UILabel *levelLabel;

@property HRPGGoldView *goldView;

@property HRPGGemView *gemView;

@property User *user;

@end

@implementation HRPGUserTopHeader

NSInteger barHeight = 5;
NSInteger rowHeight;
NSInteger rowWidth;
NSInteger margin = 3;
NSInteger rowOffset = 145;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        rowHeight = (self.frame.size.height-(margin*2))/4;
        rowWidth = self.frame.size.width-rowOffset-margin;
        
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 140, 147)];
        [self addSubview:self.avatarImageView];
        
        NIKFontAwesomeIconFactory *iconFactory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
        iconFactory.size = 15;
        iconFactory.renderingMode = UIImageRenderingModeAlwaysTemplate;
        
        self.healthLabel = [[HRPGLabeledProgressBar alloc] initWithFrame:CGRectMake(rowOffset, margin, rowWidth, rowHeight)];
        self.healthLabel.color = [UIColor colorWithRed:0.773 green:0.235 blue:0.247 alpha:1.000];
        self.healthLabel.progressBar.backgroundColor = [UIColor colorWithRed:0.976 green:0.925 blue:0.925 alpha:1.000];
        self.healthLabel.icon = [iconFactory createImageForIcon:NIKFontAwesomeIconHeart];
        [self addSubview:self.healthLabel];
        
        self.experienceLabel = [[HRPGLabeledProgressBar alloc] initWithFrame:CGRectMake(rowOffset, margin+rowHeight, rowWidth, rowHeight)];
        self.experienceLabel.color = [UIColor colorWithRed:0.969 green:0.765 blue:0.027 alpha:1.000];
        self.experienceLabel.progressBar.backgroundColor = [UIColor colorWithRed:0.996 green:0.980 blue:0.922 alpha:1.000];
        self.experienceLabel.icon = [iconFactory createImageForIcon:NIKFontAwesomeIconStar];
        [self addSubview:self.experienceLabel];
        
        self.magicLabel = [[HRPGLabeledProgressBar alloc] initWithFrame:CGRectMake(rowOffset, margin+rowHeight*2, rowWidth, rowHeight)];
        self.magicLabel.color = [UIColor colorWithRed:0.259 green:0.412 blue:0.902 alpha:1.000];
        self.magicLabel.progressBar.backgroundColor = [UIColor colorWithRed:0.925 green:0.945 blue:0.992 alpha:1.000];
        self.magicLabel.icon = [iconFactory createImageForIcon:NIKFontAwesomeIconFire];
        [self addSubview:self.magicLabel];
        
        self.levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(rowOffset+20, self.frame.size.height-27.5, 45, 20)];
        self.levelLabel.font = [UIFont systemFontOfSize:13];
        self.levelLabel.textColor = [UIColor whiteColor];
        self.levelLabel.backgroundColor = [UIColor blackColor];
        self.levelLabel.textAlignment = NSTextAlignmentCenter;
        self.levelLabel.layer.borderColor = [UIColor blackColor].CGColor;
        self.levelLabel.layer.borderWidth = 0.5;
        [self addSubview:self.levelLabel];
        
        self.goldView = [[HRPGGoldView alloc] initWithFrame:CGRectMake(rowOffset+(rowWidth+margin)/2, margin+rowHeight*3+(rowHeight-20)/2, (rowWidth-margin)/2, 20)];
        [self addSubview:self.goldView];
        
        self.gemView = [[HRPGGemView alloc] initWithFrame:CGRectMake(rowOffset, margin+rowHeight*3+(rowHeight-20)/2, (rowWidth-margin)/2, 20)];
        [self addSubview:self.gemView];
        
        [self setData];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(resetUser:)
         name:@"userChanged"
         object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@", [keyChain stringForKey:@"id"]]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    rowHeight = (self.frame.size.height-(margin*2))/4;
    rowWidth = self.frame.size.width-rowOffset-margin;
    self.healthLabel.frame = CGRectMake(rowOffset, margin, rowWidth, rowHeight);
    self.experienceLabel.frame = CGRectMake(rowOffset, margin+rowHeight, rowWidth, rowHeight);
    self.magicLabel.frame = CGRectMake(rowOffset, margin+rowHeight*2, rowWidth, rowHeight);
    self.goldView.frame = CGRectMake(rowOffset+rowWidth-self.goldView.frame.size.width, self.goldView.frame.origin.y, self.goldView.frame.size.width, self.goldView.frame.size.height);
    self.gemView.frame = CGRectMake(self.goldView.frame.origin.x-self.gemView.frame.size.width-8, self.gemView.frame.origin.y, self.gemView.frame.size.width, self.gemView.frame.size.height);
}

- (HRPGManager *)sharedManager {
    if (_sharedManager == nil) {
        HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
        _sharedManager = appdelegate.sharedManager;
    }
    return _sharedManager;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext == nil) {
        _managedObjectContext = self.sharedManager.getManagedObjectContext;
    }
    return _managedObjectContext;
}

- (void) setData {
    self.user = [self getUser];
    [self.user setAvatarOnImageView:self.avatarImageView withPetMount:YES onlyHead:NO withBackground:YES useForce:YES];
    self.healthLabel.value = self.user.health;
    if ([self.user.maxHealth integerValue] > 0) {
        self.healthLabel.maxValue = self.user.maxHealth;
    }

    self.experienceLabel.value = self.user.experience;
    if ([self.user.nextLevel integerValue] > 0) {
        self.experienceLabel.maxValue = self.user.nextLevel;
    }

    if ([self.user.level integerValue] >= 10) {
        self.magicLabel.value = self.user.magic;
        if ([self.user.maxMagic integerValue] > 0) {
            self.magicLabel.maxValue = self.user.maxMagic;
        }
        self.magicLabel.hidden = NO;
    } else {
        self.magicLabel.hidden = YES;
    }
    
    self.levelLabel.text = [NSString stringWithFormat:NSLocalizedString(@"lvl %@", nil), self.user.level];
    self.levelLabel.backgroundColor = self.user.contributorColor;
    [self.levelLabel sizeToFit];
    self.levelLabel.frame = CGRectMake(122.5-self.levelLabel.frame.size.width, self.levelLabel.frame.origin.y, self.levelLabel.frame.size.width+10, 20);
    [self.goldView updateView:self.user.gold withDiffString:nil];
    [self.goldView sizeToFit];
    self.goldView.frame = CGRectMake(rowOffset+rowWidth-self.goldView.frame.size.width, self.goldView.frame.origin.y, self.goldView.frame.size.width, self.goldView.frame.size.height);
    [self.gemView updateViewWithGemcount:[NSNumber numberWithFloat:[self.user.balance floatValue]*4] withDiffString:nil];
    [self.gemView sizeToFit];
    self.gemView.frame = CGRectMake(self.goldView.frame.origin.x-self.gemView.frame.size.width-8, self.gemView.frame.origin.y, self.gemView.frame.size.width, self.gemView.frame.size.height);
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    [self setData];
}

- (User*)getUser {
    if ([[self.fetchedResultsController sections] count] > 0) {
        if ([[self.fetchedResultsController sections][0] numberOfObjects] > 0) {
            return (User *) [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        }
    }
    
    return nil;
}

- (void)resetUser:(NSNotification *)notification {
    self.fetchedResultsController = nil;
    [self setData];
}

@end
