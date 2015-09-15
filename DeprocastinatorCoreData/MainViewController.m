//
//  ViewController.m
//  DeprocastinatorCoreData
//
//  Created by Achyut Kumar Maddela on 14/09/15.
//  Copyright (c) 2015 iAKM. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "Task.h"

@interface MainViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property NSMutableArray *tasks;
@property NSIndexPath *deleteIndexPath;
@property NSManagedObjectContext *moc;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tasks = [NSMutableArray new];
    self.addButton.enabled = NO;

    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.moc = delegate.managedObjectContext;
    [self loadTasks];

    //this creates edit/done button
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
    self.editButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    //tap gesture recg to dismiss keyboard when tapped outside textfield
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

    //a simple yet powerful line of code which doesnt obstruct tapping another buttons
    tap.cancelsTouchesInView = NO;

  //  tap gesture recg to enable swiping right for priority
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:recognizer];

}


#pragma mark - Selector Methods
#pragma mark -
-(void)cellSwiped:(UIGestureRecognizer *) gestureRecognizer
{
    //setting location for the swipe
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    //setting indexpath
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];

    if (indexPath)
    {
        Task *eachTask = [self.tasks objectAtIndex:indexPath.row];
        int temp = [eachTask.priority intValue];

        if (temp < 3)
        {
            temp ++;
            [eachTask setPriority:[NSNumber numberWithInt:temp]];
        }
        else
        {
            [eachTask setPriority:0];
        }
        [self.moc save:nil];
        [self.tableView reloadData];

    }

}
//selector method for dismissing keyboard
-(void)dismissKeyboard {
    [self.textField resignFirstResponder];
}

#pragma mark - Helper Methods
#pragma mark -
-(void)loadTasks
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES]];

    self.tasks = (NSMutableArray *)[self.moc executeFetchRequest:request error:nil];
    [self.tableView reloadData];

}

#pragma mark - Action Methods
#pragma mark -
- (IBAction)onAddButtonPressed:(UIButton *)sender {

    Task *newTask = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.moc];
    newTask.priority = 0;
    newTask.isChecked = 0;

    if (self.tasks.count <=0)
    {
        newTask.displayOrder = [NSNumber numberWithInteger:1];
    }
    else
    {
        newTask.displayOrder = [NSNumber numberWithInteger:self.tasks.count + 1];

    }

    [newTask setValue:self.textField.text forKey:@"taskName"];
    [self.moc save:nil];
    [self loadTasks];
    self.textField.text = @"";
    [self.textField endEditing:YES];
    [self.textField resignFirstResponder];


    [self.tableView reloadData];
    self.addButton.enabled = NO;
}
//enables button only if textfield has text
- (IBAction)onTextEntered:(UITextField *)sender {

    if ([self.textField hasText])
    {
        self.addButton.enabled = YES;
    }
    else
    {
        self.addButton.enabled = NO;
    }

}

#pragma mark - UITableView DataSource & Delegate Methods
#pragma mark -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tasks.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    Task *task = [self.tasks objectAtIndex:indexPath.row];

    cell.textLabel.text = task.taskName;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *eachTask = [self.tasks objectAtIndex:indexPath.row];

    if ([eachTask.isChecked isEqual:@1])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    if ([eachTask.priority isEqual:@1])
    {
        cell.backgroundColor = [UIColor blueColor];
    }
    else if ([eachTask.priority isEqual:@2])
    {
        cell.backgroundColor = [UIColor yellowColor];

    }
    else if ([eachTask.priority isEqual:@3])
    {
        cell.backgroundColor = [UIColor orangeColor];
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
         self.deleteIndexPath = indexPath;

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you Sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}
// index = 1 ---> YES button
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self.moc deleteObject:[self.tasks objectAtIndex:self.deleteIndexPath.row]];
        [self.tableView beginUpdates];

        id tmp = [self.tasks mutableCopy];
        [tmp removeObjectAtIndex:self.deleteIndexPath.row];
        self.tasks = [tmp copy];

        [self.tableView deleteRowsAtIndexPaths:@[self.deleteIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        [self.moc save:nil];

    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;

}


-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    Task *task = [self.tasks objectAtIndex:sourceIndexPath.row];
    [tableView beginUpdates];

    id tmp = [self.tasks mutableCopy];
    [tmp removeObjectAtIndex:sourceIndexPath.row];
    [tmp insertObject:task atIndex:destinationIndexPath.row];
    self.tasks = [tmp copy];

    [tableView deleteRowsAtIndexPaths:@[sourceIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView insertRowsAtIndexPaths:@[destinationIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];

    for (Task *eachTask in self.tasks) {
        [eachTask setValue:[NSNumber numberWithInteger:[self.tasks indexOfObject:eachTask]] forKey:@"displayOrder"];
    }
    [self.moc save:nil];
    [self loadTasks];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *eachTask = [self.tasks objectAtIndex:indexPath.row];

    if ([eachTask.isChecked isEqual:@1])
    {
        [eachTask setValue:@0 forKey:@"isChecked"];
        NSLog(@"unchecked");
        [self.moc save:nil];

    }
    else
    {
        [eachTask setValue:@1 forKey:@"isChecked"];
        NSLog(@"checked");
        [self.moc save:nil];
        
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self loadTasks];

}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (editing)
    {
        [self.tableView setEditing:YES animated:YES];
        [self.tableView reloadData];

    }
    else
    {
        [self.tableView setEditing:NO animated:YES];
        [self.tableView reloadData];
        
        
    }
}



@end
