//
//  CKFiltersForMapViewController.m
//  click
//
//  Created by Anatoly Mityaev on 25.10.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKFiltersForMapViewController.h"
#import "CKCountryCell.h"
#define kOFFSET_FOR_KEYBOARD 80.0

@interface CKFiltersForMapViewController ()

@property (nonatomic, retain) UIPickerView *selectAgeFrom;
@property (nonatomic, retain) UIPickerView *selectAgeTo;
@property (nonatomic, retain) NSArray *pickerData;
@property (nonatomic, retain) NSArray *pickerData1;

@end

@implementation CKFiltersForMapViewController
{
    CKMapViewController *map;
    UILabel *lb;
    UISwitch *sw;
    UIView *view1;
    
    UIView *view2;
    UILabel *chooseAge;
    UILabel *age;
    UIButton *selectAge;;
    
    UIView *view3;
    UILabel *chooseSex;
    UILabel *sexLabel;
    UIButton *selectSex;
    
    UIView *view4;
    UIImageView *countryImage;
    UILabel *countryName;
    UIButton *selectCountry;
    
    UIView *view5;
    UIView *cityImage;
    UILabel *cityName;
    UIButton *selectCity;
    
    UIView *view6;
    UIView *search;
    UITextField *searchTextField;
    UIButton *deleteEntering;
    UISegmentedControl *allPeopleOrFriends;
    
    UIView *viewForAgeSelection;
    __weak UIView *viewForAgeSelectionDark;
    UILabel *ageFrom;
    UILabel *ageTo;
    UIButton *select;
    UILabel *textLabel;
    NSArray *segmentItemsArray;
    
    NSMutableArray *data;
    NSMutableArray *data1;
    
    NSString *sexTest;
    NSNumber *minageTest;
    NSNumber *maxageTest;
    NSNumber *minAgeBeforeSelection;
    NSNumber *maxAgeBeforeSelection;
    NSString *nameTest;
    NSString *countryTest;
    NSInteger countryIdTest;
    NSString *cityTest;
    NSInteger cityIdTest;
    NSInteger countryImageIsoTest;
    BOOL allUsersTest;
    
    UIButton *cancelFilters;
    CGFloat _keyboardHeight;
    int countViewUp;
    BOOL _isKeyboardHidden;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.title = @"Карта";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Отменить" style: UIBarButtonItemStylePlain target:self action:@selector(dismissClick)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Применить" style: UIBarButtonItemStylePlain target:self action:@selector(submitClick)];
    }
    return self;
}

- (void)dismissClick
{
    _endWithCancelFilters = NO;
    if ([_minage  isEqual: @0] && [_maxage  isEqual: @0])
    {
        age.text = [NSString stringWithFormat:@"%@-%@", @14, @99];
    }
    else
    {
        age.text = [NSString stringWithFormat:@"%@-%@", _minage, _maxage];
    }
    sexLabel.text = [NSString stringWithFormat:@"%@", _sex];
    searchTextField.text = _name;
    if ([_city isEqual:@""]) cityName.text = @"Любой город";
    else cityName.text = _city;
    if ([_country isEqual:@""])
    {
        countryName.text = @"Любая страна";
        [countryImage setImage:nil];
    }
    else
    {
        countryName.text = _country;
        [countryImage setImage:[UIImage imageNamed: [NSString stringWithFormat:@"%ld", (long)_countryImageIso]]];
    }
    countryIdTest = 0;
    _endWithSumbit = false;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)submitClick
{
    _endWithCancelFilters = NO;
    _minage = minageTest;
    _maxage = maxageTest;
    if ([_minage  isEqual: @14] && [_maxage  isEqual: @99])
    {
        _minage = @0;
        _maxage = @0;
    }
    _sex = sexTest;
    nameTest = searchTextField.text;
    _name = nameTest;
    _countryId = countryIdTest;
    _country = countryTest;
    _cityId = cityIdTest;
    _city = cityTest;
    _countryImageIso = countryImageIsoTest;
    _allUsers = allUsersTest;
    _endWithSumbit = true;
    [self dismissViewControllerAnimated:YES completion:^{
        map.sexT = _sex;
        map.minageT = _minage;
        map.maxageT = _maxage;
    }];
}

- (void)viewDidLoad
{
    map = [CKMapViewController new];
    countViewUp = 1;
    sexTest = _sex;
    minageTest = _minage;
    maxageTest = _maxage;
    allUsersTest = _allUsers;
    nameTest = _name;
    countryIdTest = _countryId;
    countryTest = _country;
    cityIdTest = _cityId;
    cityTest = _city;
    countryImageIsoTest = _countryImageIso;
    
    segmentItemsArray = [NSArray arrayWithObjects: @"Все", @"Контакты", nil];
    
    view1 = [UIView new];
    [self.view addSubview:view1];
    view1.backgroundColor = [UIColor whiteColor];
    view1.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.6].CGColor;
    view1.layer.borderWidth = 0.5f;
    [view1 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(self.view.top).offset(@60);
        make.right.equalTo(self.view.right);
        make.height.equalTo(@50);
    }];
    
    lb = [UILabel new];
    [self.view addSubview:lb];
    lb.text = @"Показывать мое местоположение";
    [lb setFont:[UIFont systemFontOfSize:14]];
    [lb makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1.left).offset(@20);
        make.top.equalTo(view1.top).offset(@20);
        make.width.equalTo(@220);
    }];
    
    sw = [UISwitch new];
    if (_switchOn == true) [sw setOn:YES];
    else [sw setOn:NO];
    [self.view addSubview:sw];
    [sw makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view1.right).offset(@-10);
        make.top.equalTo(view1.top).offset(@12);
    }];
    
    view2 = [UIView new];
    [self.view addSubview:view2];
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(selectAgePicker)];
    [view2 addGestureRecognizer:singleFingerTap];
    view2.backgroundColor = [UIColor whiteColor];
    view2.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.6].CGColor;
    view2.layer.borderWidth = 0.5f;
    [view2 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(view1.bottom).offset(@20);
        make.right.equalTo(self.view.right);
        make.height.equalTo(@40);
    }];
    
    chooseAge = [UILabel new];
    [self.view addSubview:chooseAge];
    chooseAge.text = @"Возраст";
    [chooseAge setFont:[UIFont systemFontOfSize:14]];
    [chooseAge makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view2.left).offset(@20);
        make.top.equalTo(view2.top).offset(@10);
        make.width.equalTo(@220);
    }];
    
    selectAge = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImage = [UIImage imageNamed:@"arrow_right_gray"];
    [selectAge setImage:btnImage forState:UIControlStateNormal];
    [self.view addSubview:selectAge];
    [selectAge makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view2.right).offset(@-10);
        make.top.equalTo(view2.top).offset(@11);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    [selectAge addTarget:self action:@selector(selectAgePicker) forControlEvents:UIControlEventTouchUpInside];
    
    age = [UILabel new];
    [self.view addSubview:age];
    if ([_minage  isEqual: @0] && [_maxage  isEqual: @0])
    {
        _minage = @14;
        _maxage = @99;
        //        minageTest = _minage;
        //        maxageTest = _maxage;
    }
    if ([minageTest isEqual:@0] && [maxageTest isEqual:@0])
    {
        minAgeBeforeSelection = @14;
        maxAgeBeforeSelection = @99;
    }
    else
    {
        minAgeBeforeSelection = minageTest;
        maxAgeBeforeSelection = maxageTest;
    }
    
    age.text = [NSString stringWithFormat:@"%@-%@", minAgeBeforeSelection, maxAgeBeforeSelection];
    [age setFont:[UIFont systemFontOfSize:14]];
    [age setTextColor:[UIColor grayColor]];
    [age makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(selectAge.left).offset(@-10);
        make.top.equalTo(view2.top).offset(@10);
        make.width.equalTo(@50);
    }];
    
    
    view3 = [UIView new];
    [self.view addSubview:view3];
    UITapGestureRecognizer *singleFingerTap1 =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(selectSexPicker)];
    [view3 addGestureRecognizer:singleFingerTap1];
    view3.backgroundColor = [UIColor whiteColor];
    view3.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.6].CGColor;
    view3.layer.borderWidth = 0.5f;
    [view3 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(view2.bottom).offset(@-1);
        make.right.equalTo(self.view.right);
        make.height.equalTo(@40);
    }];
    
    chooseSex = [UILabel new];
    [self.view addSubview:chooseSex];
    chooseSex.text = @"Пол";
    [chooseSex setFont:[UIFont systemFontOfSize:14]];
    [chooseSex makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view3.left).offset(@20);
        make.top.equalTo(view3.top).offset(@10);
        make.width.equalTo(@220);
    }];
    
    selectSex = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImage1 = [UIImage imageNamed:@"arrow_right_gray"];
    [selectSex setImage:btnImage1 forState:UIControlStateNormal];
    [self.view addSubview:selectSex];
    [selectSex makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view3.right).offset(@-10);
        make.top.equalTo(view3.top).offset(@11);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    [selectSex addTarget:self action:@selector(selectSexPicker) forControlEvents:UIControlEventTouchUpInside];
    
    sexLabel = [UILabel new];
    [self.view addSubview:sexLabel];
    sexLabel.text = [NSString stringWithFormat:@"%@", _sex];
    [sexLabel setFont:[UIFont systemFontOfSize:14]];
    [sexLabel setTextColor:[UIColor grayColor]];
    [sexLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(selectSex.left).offset(@-10);
        make.top.equalTo(view3.top).offset(@10);
        make.width.equalTo(@70);
    }];
    
    view4 = [UIView new];
    [self.view addSubview:view4];
    UITapGestureRecognizer *singleFingerTap2 =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(selectCountry)];
    [view4 addGestureRecognizer:singleFingerTap2];
    view4.backgroundColor = [UIColor whiteColor];
    view4.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.6].CGColor;
    view4.layer.borderWidth = 0.5f;
    [view4 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(view3.bottom).offset(@-1);
        make.right.equalTo(self.view.right);
        make.height.equalTo(@40);
    }];
    
    if (_countryImageIso !=0)
        countryImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: [NSString stringWithFormat:@"%ld", (long)_countryImageIso]]];
    else
        countryImage = [UIImageView new];
    [self.view addSubview:countryImage];
    
    //[countryImage setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed: [NSString stringWithFormat:@"%ld", (long)_countryImageIso]]]];
    [countryImage makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view4.left).offset(@10);
        make.top.equalTo(view4.top).offset(@7);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    
    countryName = [UILabel new];
    [self.view addSubview:countryName];
    if ([_country isEqual:@""]) countryName.text = @"Любая страна";
    else countryName.text = _country;
    [countryName setFont:[UIFont systemFontOfSize:14]];
    [countryName makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(countryImage.right).offset(@10);
        make.top.equalTo(view4.top).offset(@10);
        make.width.equalTo(@220);
    }];
    
    selectCountry = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImage4 = [UIImage imageNamed:@"arrow_right_gray"];
    [selectCountry setImage:btnImage4 forState:UIControlStateNormal];
    [self.view addSubview:selectCountry];
    [selectCountry makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view4.right).offset(@-10);
        make.top.equalTo(view4.top).offset(@11);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    [selectCountry addTarget:self action:@selector(selectCountry) forControlEvents:UIControlEventTouchUpInside];
    
    view5 = [UIView new];
    [self.view addSubview:view5];
    UITapGestureRecognizer *singleFingerTap3 =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(selectCity)];
    [view5 addGestureRecognizer:singleFingerTap3];
    view5.backgroundColor = [UIColor whiteColor];
    view5.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.6].CGColor;
    view5.layer.borderWidth = 0.5f;
    [view5 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(view4.bottom).offset(@-1);
        make.right.equalTo(self.view.right);
        make.height.equalTo(@40);
    }];
    
    cityName = [UILabel new];
    [self.view addSubview:cityName];
    if ([_city isEqual:@""]) cityName.text = @"Любой город";
    else cityName.text = _city;
    [cityName setFont:[UIFont systemFontOfSize:14]];
    [cityName makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view5.left).offset(@40);
        make.top.equalTo(view5.top).offset(@10);
        make.width.equalTo(@220);
    }];
    
    selectCity = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImage5 = [UIImage imageNamed:@"arrow_right_gray"];
    [selectCity setImage:btnImage5 forState:UIControlStateNormal];
    [self.view addSubview:selectCity];
    [selectCity makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view5.right).offset(@-10);
        make.top.equalTo(view5.top).offset(@11);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    [selectCity addTarget:self action:@selector(selectCity) forControlEvents:UIControlEventTouchUpInside];
    
    view6 = [UIView new];
    [self.view addSubview:view6];
    view6.backgroundColor = [UIColor whiteColor];
    view6.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.6].CGColor;
    view6.layer.borderWidth = 0.5f;
    view6.layer.cornerRadius = 10.0;
    [view6 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(@10);
        make.top.equalTo(view5.bottom).offset(@10);
        make.right.equalTo(self.view.right).offset(@-10);
        make.height.equalTo(@30);
    }];
    
    search = [UIView new];
    [self.view addSubview:search];
    [search setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"magnifier_left_gray"]]];
    [search makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view6.left).offset(@8);
        make.top.equalTo(view6.top).offset(@8);
        make.width.equalTo(@12);
        make.height.equalTo(@12);
    }];
    
    deleteEntering = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *delBtnImage = [UIImage imageNamed:@"cross_small_gray"];
    [deleteEntering setImage:delBtnImage forState:UIControlStateNormal];
    [self.view addSubview:deleteEntering];
    [deleteEntering makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view6.right).offset(@-5);
        make.top.equalTo(view6.top).offset(@5);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    [deleteEntering addTarget:self action:@selector(clearTextField) forControlEvents:UIControlEventTouchUpInside];
    
    
    allPeopleOrFriends = [[UISegmentedControl alloc] initWithItems:segmentItemsArray];
    
    if (allUsersTest == true) allPeopleOrFriends.selectedSegmentIndex = 0;
    else allPeopleOrFriends.selectedSegmentIndex = 1;
    [self.view addSubview:allPeopleOrFriends];
    [allPeopleOrFriends addTarget:self action:@selector(segmentControlAction:) forControlEvents:UIControlEventValueChanged];
    [allPeopleOrFriends makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view6.bottom).offset(@5);
        make.left.equalTo(self.view.left).offset(@70);
        make.right.equalTo(self.view.right).offset(@-70);
        make.height.equalTo(@30);
    }];
    
    searchTextField = [UITextField new];
    [self.view addSubview:searchTextField];
    [searchTextField makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(search.right).offset(@5);
        make.right.equalTo(deleteEntering.left).offset(@-5);
        make.top.equalTo(view6.top);
        make.bottom.equalTo(view6.bottom);
    }];
    
    cancelFilters = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelFilters setTitle:@"Отменить фильтры" forState:UIControlStateNormal];
    [cancelFilters setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.view addSubview:cancelFilters];
    [cancelFilters makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom).offset(@-20);
        make.right.equalTo(self.view.right).offset(@-70);
        make.left.equalTo(self.view.left).offset(@70);
        make.height.equalTo(@30);
    }];
    [cancelFilters addTarget:self action:@selector(cancelFilters) forControlEvents:UIControlEventTouchUpInside];
}

- (void) viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];
    
    
    data = [NSMutableArray new];
    data1 = [NSMutableArray new];
    for (int i = 14; i<=99; i++)
    {
        [data addObject:@(i)];
        if (i != 14)
        {
            [data1 addObject:@(i)];
        }
    }
    _pickerData = data;
    _pickerData1 = data1;
}

- (void) keyboardWillShow:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y -100., self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
    
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y +100., self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}


- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void) countrySelectionController:(CKCountrySelectionController *)controller didSelectCountryWithId:(NSInteger)id name:(NSString *)name code:(NSNumber *)code
{
    NSDictionary *countryDic = [[CKApplicationModel sharedInstance] countryWithId:id];
    countryImageIsoTest = [countryDic[@"iso"] integerValue];
    //countryImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: [NSString stringWithFormat:@"%ld", (long)_countryImageIso]]];
    [countryImage setImage:[UIImage imageNamed: [NSString stringWithFormat:@"%ld", (long)countryImageIsoTest]]];
    countryIdTest = id;
    countryTest = countryDic[@"name"];
    countryName.text = countryTest;
    cityIdTest = 0;
    cityTest = @"";
    cityName.text = @"Любой город";
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) selectCountry
{
    CKCountrySelectionController *controller = [CKCountrySelectionController new];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)citySelectionController:(CKCitySelectionController *)controller didSelectCityWithId:(NSInteger)id name:(NSString *)name
{
    cityIdTest = id;
    cityTest = name;
    cityName.text = cityTest;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) selectCity
{
    if (countryIdTest !=0)
    {
        CKCitySelectionController *controller = [CKCitySelectionController new];
        controller.countryId = countryIdTest;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }
}
- (void) cancelFilters{
    _minage = @0;
    _maxage = @0;
    _sex = @"";
    _name = @"";
    _allUsers = true;
    _endWithSumbit = true;
    age.text = [NSString stringWithFormat:@"%@-%@", _minage, _maxage];
    sexLabel.text = [NSString stringWithFormat:@"%@", _sex];
    searchTextField.text = _name;
    _countryId = 0;
    _cityId = 0;
    _country = @"";
    _city = @"";
    [countryImage setImage:nil];
    countryName.text = @"Любая страна";
    cityName.text = @"Любой город";
    countryIdTest = 0;
    _endWithSumbit = false;
    _endWithCancelFilters = YES;
    [self dismissViewControllerAnimated:YES completion:^{
        map.sexT = _sex;
        map.minageT = _minage;
        map.maxageT = _maxage;
        map.nameT = _name;
        map.allUsersT = _allUsers;
    }];
}
- (void) clearTextField
{
    searchTextField.text = @"";
}

- (void) segmentControlAction:(UISegmentedControl *)segment
{
    if(segment.selectedSegmentIndex == 0)
    {
        allUsersTest = true;
    }
    else
    {
        allUsersTest = false;
    }
}


- (void) selectAgePicker
{
    
    UINavigationController *navContr = [[UINavigationController alloc] init];
    viewForAgeSelectionDark = navContr.view;
    [self.view addSubview:viewForAgeSelectionDark];
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(closeAgeSelection)];
    [viewForAgeSelectionDark addGestureRecognizer:singleFingerTap];
    
    viewForAgeSelectionDark.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.4f];
    [viewForAgeSelectionDark makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(self.view.top);
        make.right.equalTo(self.view.right);
        make.bottom.equalTo(self.view.bottom);
    }];
    
    viewForAgeSelection = [UIView new];
    [self.view addSubview:viewForAgeSelection];
    viewForAgeSelection.backgroundColor = [UIColor whiteColor];
    [viewForAgeSelection makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.centerY.equalTo(@0);
        make.width.equalTo(@300);
        make.height.equalTo(@260);
    }];
    
    textLabel = [UILabel new];
    [self.view addSubview:textLabel];
    [textLabel setFont:[UIFont systemFontOfSize:16]];
    textLabel.text = @"Выберите возрастной диапазон:";
    textLabel.textColor = [UIColor blackColor];
    [textLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewForAgeSelection.top).offset(@10);
        make.left.equalTo(viewForAgeSelection.left).offset(@20);
        make.right.equalTo(viewForAgeSelection.right).offset(@-20);
        make.height.equalTo(@30);
    }];
    
    ageFrom = [UILabel new];
    [self.view addSubview:ageFrom];
    [ageFrom setFont:[UIFont systemFontOfSize:14]];
    ageFrom.text = @"От:";
    ageFrom.textAlignment = NSTextAlignmentCenter;
    ageFrom.textColor = [UIColor blackColor];
    [ageFrom makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textLabel.bottom).offset(@5);
        make.left.equalTo(viewForAgeSelection.left);
        make.width.equalTo(@150);
        make.height.equalTo(@30);
    }];
    
    ageTo = [UILabel new];
    [self.view addSubview:ageTo];
    [ageTo setFont:[UIFont systemFontOfSize:14]];
    ageTo.text = @"До:";
    ageTo.textAlignment = NSTextAlignmentCenter;
    ageTo.textColor = [UIColor blackColor];
    [ageTo makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textLabel.bottom).offset(@5);
        make.right.equalTo(viewForAgeSelection.right);
        make.width.equalTo(@150);
        make.height.equalTo(@30);
    }];
    
    _selectAgeFrom = [UIPickerView new];
    _selectAgeFrom.showsSelectionIndicator = YES;
    _selectAgeFrom.hidden = NO;
    _selectAgeFrom.delegate = self;
    [self.view addSubview:_selectAgeFrom];
    //    _selectAgeFrom.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.6].CGColor;
    //    _selectAgeFrom.layer.borderWidth = 0.8f;
    [_selectAgeFrom makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ageFrom.bottom).offset(@10);
        make.left.equalTo(viewForAgeSelection.left).offset(@25);
        make.width.equalTo(@100);
        make.height.equalTo(@100);
    }];
    _selectAgeFrom.tag = 1;
    
    _selectAgeTo = [UIPickerView new];
    _selectAgeTo.showsSelectionIndicator = YES;
    _selectAgeTo.hidden = NO;
    _selectAgeTo.delegate = self;
    [self.view addSubview:_selectAgeTo];
    //    _selectAgeTo.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.6].CGColor;
    //    _selectAgeTo.layer.borderWidth = 0.8f;
    [_selectAgeTo makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ageTo.bottom).offset(@10);
        make.right.equalTo(viewForAgeSelection.right).offset(@-25);
        make.width.equalTo(@100);
        make.height.equalTo(@100);
    }];
    _selectAgeTo.tag = 2;
    
    select = [UIButton buttonWithType:UIButtonTypeCustom];
    [select setTitle:@"Выбрать" forState:UIControlStateNormal];
    [select setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:select];
    [select makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(viewForAgeSelection.bottom).offset(@-20);
        //make.centerY.equalTo(viewForAgeSelection.centerY);
        make.right.equalTo(viewForAgeSelection.right).offset(@-70);
        make.left.equalTo(viewForAgeSelection.left).offset(@70);
        make.height.equalTo(@30);
    }];
    [select addTarget:self action:@selector(selectMinMaxAge) forControlEvents:UIControlEventTouchUpInside];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if ([pickerView isEqual:_selectAgeFrom])
    {
        return _pickerData.count;
    }
    else return _pickerData1.count;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
    {
        return [_pickerData objectAtIndex:row];
    }
    else return [_pickerData1 objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
    {
        NSString *selValue = [_pickerData objectAtIndex:[_selectAgeFrom selectedRowInComponent:0]];
        int r = [selValue intValue];
        minageTest = @(r);
        data1 = [NSMutableArray new];
        for (int i = r + 1; i<= 99; i++)
        {
            [data1 addObject:@(i)];
        }
        _pickerData1 = data1;
        [_selectAgeTo reloadAllComponents];
        
    }
    else
    {
        NSString *selValue = [_pickerData1 objectAtIndex:[_selectAgeTo selectedRowInComponent:0]];
        int r = [selValue intValue];
        maxageTest = @(r);
        data = [NSMutableArray new];
        for (int i = 14; i<= r - 1; i++)
        {
            [data addObject:@(i)];
        }
        _pickerData = data;
        [_selectAgeFrom reloadAllComponents];
        
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 37)];
    
    if (component == 0) {
        
        label.font=[UIFont boldSystemFontOfSize:22];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        
        if (pickerView.tag ==1)
        {
            label.text = [NSString stringWithFormat:@"%@", [_pickerData objectAtIndex:row]];
        }
        else label.text = [NSString stringWithFormat:@"%@", [_pickerData1 objectAtIndex:row]];
        label.font=[UIFont boldSystemFontOfSize:22];
        
    }
    return label;
}

- (void) selectSexPicker
{
    UIAlertController *sexPicker = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Любой" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        sexTest = action.title;
        sexLabel.text = sexTest;
    }];
    [sexPicker addAction:action];
    
    action = [UIAlertAction actionWithTitle:@"Мужской" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        sexTest = action.title;
        sexLabel.text = sexTest;
    }];
    [sexPicker addAction:action];
    
    action = [UIAlertAction actionWithTitle:@"Женский" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        sexTest = action.title;
        sexLabel.text = sexTest;
    }];
    [sexPicker addAction:action];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Отменить" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [sexPicker addAction:cancel];
    
    [self presentViewController:sexPicker
                       animated:YES
                     completion:nil];
    
}

- (void) selectMinMaxAge
{
    if ([minageTest integerValue] >= [maxageTest integerValue] /*|| [maxageTest integerValue] == 99*/)
    {
        //maxageTest = [NSNumber numberWithInt: [minageTest intValue] + 1];
        maxageTest = _pickerData1[0];
    }
    if ([minageTest integerValue] < [maxageTest integerValue])
    {
        viewForAgeSelection.hidden = YES;
        viewForAgeSelectionDark.hidden = YES;
        minAgeBeforeSelection = minageTest;
        maxAgeBeforeSelection = maxageTest;
        textLabel.hidden = YES;
        ageFrom.hidden = YES;
        ageTo.hidden = YES;
        _selectAgeFrom.hidden = YES;
        _selectAgeTo.hidden = YES;
        select.hidden = YES;
        age.text = [NSString stringWithFormat:@"%@-%@", minageTest, maxageTest];
    }
}

- (void) closeAgeSelection
{
    minageTest = minAgeBeforeSelection;
    maxageTest = maxAgeBeforeSelection;
    viewForAgeSelection.hidden = YES;
    viewForAgeSelectionDark.hidden = YES;
    textLabel.hidden = YES;
    ageFrom.hidden = YES;
    ageTo.hidden = YES;
    _selectAgeFrom.hidden = YES;
    _selectAgeTo.hidden = YES;
    select.hidden = YES;
    age.text = [NSString stringWithFormat:@"%@-%@", minAgeBeforeSelection, maxAgeBeforeSelection];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y -200., self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y +200., self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

- (void) tapScreen
{
    [self.view endEditing:YES];
}

@end
