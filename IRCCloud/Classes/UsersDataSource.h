//
//  UsersDataSource.h
//
//  Copyright (C) 2013 IRCCloud, Ltd.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#import <Foundation/Foundation.h>

@interface User : NSObject {
    int _cid;
    int _bid;
    NSString *_nick;
    NSString *_old_nick;
    NSString *_hostmask;
    NSString *_mode;
    int _away;
    NSString *_away_msg;
}
@property int cid, bid, away;
@property NSString *nick, *old_nick, *hostmask, *mode, *away_msg;
-(NSComparisonResult)compare:(User *)aUser;
@end

@interface UsersDataSource : NSObject {
    NSMutableArray *_users;
}
+(UsersDataSource *)sharedInstance;
-(void)clear;
-(void)addUser:(User *)user;
-(NSArray *)usersForBuffer:(int)bid;
-(User *)getUser:(NSString *)nick cid:(int)cid bid:(int)bid;
-(User *)getUser:(NSString *)nick cid:(int)cid;
-(void)removeUser:(NSString *)nick cid:(int)cid bid:(int)bid;
-(void)removeUsersForBuffer:(int)bid;
-(void)updateNick:(NSString *)nick oldNick:(NSString *)oldNick cid:(int)cid bid:(int)bid;
-(void)updateAway:(int)away msg:(NSString *)msg nick:(NSString *)nick cid:(int)cid bid:(int)bid;
-(void)updateAway:(int)away nick:(NSString *)nick cid:(int)cid bid:(int)bid;
-(void)updateHostmask:(NSString *)hostmask nick:(NSString *)nick cid:(int)cid bid:(int)bid;
-(void)updateMode:(NSString *)mode nick:(NSString *)nick cid:(int)cid bid:(int)bid;
@end
