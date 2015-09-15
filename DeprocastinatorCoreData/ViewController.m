//
//  ViewController.m
//  DeprocastinatorCoreData
//
//  Created by Achyut Kumar Maddela on 14/09/15.
//  Copyright (c) 2015 iAKM. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Task.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSManagedObjectContext *moc;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property NSMutableArray *tasks;
@property NSIndexPath *dip;
@property (strong, nonatomic) IBOutlet UIButton *addButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tasks = [NSMutableArray new];

    self.addButton.enabled = NO;
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.moc = delegate.managedObjectContext;
    [self loadTasks];

    //this enables edit/done button
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
    self.editButtonItem.tintColor = [UIColor whiteColor];

    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:recognizer];

}
//selector method
-(void)cellSwiped:(UIGestureRecognizer *) gestureRecognizer
{
    //setting location for the swipe
    CGPoint location = [gestureRecognizer locationInView:self.tableView];

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

-(void)loadTasks
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES]];

    self.tasks = (NSMutableArray *)[self.moc executeFetchRequest:request error:nil];
    [self.tableView reloadData];


}
- (IBAction)onAddButtonPressed:(UIButton *)sender {

    Task *newTask = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.moc];
    newTask.priority = 0;
    newTask.isChecked = 0;

    if (self.tasks.count <=0)
    {
        newTask.displayOrder = [NSNumber numberWithInteger:0];
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
         self.dip = indexPath;

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you Sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self.moc deleteObject:[self.tasks objectAtIndex:self.dip.row]];
        [self.tableView beginUpdates];

        id tmp = [self.tasks mutableCopy];
        [tmp removeObjectAtIndex:self.dip.row];
        self.tasks = [tmp copy];

        [self.tableView deleteRowsAtIndexPaths:@[self.dip] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        [self.moc save:nil];

    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;

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

@end
