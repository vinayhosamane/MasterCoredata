# MasterCoredata
This repository is to try different uses cases in coredata.

- [x] Model Creation From Editor

- [x] CRUD Operations on Coredata managed object model

- [x] Fetching content from Entity

- [x] Handling relationships between Entities

- [x] Parent / Child Managed Object Contexts

- [x] Thread safe managed object contexts

- [x] Sharing managed objects between multiple contexts

- [ ] Transactions In Coredata, Batch Insert / Delete

- [ ] NSFetchedResultsController

- [ ] Best Practices

- [ ] Value change observers / KVO / Notifications

- [ ] Parent / Child context save merge policies

- [ ] Resolving merge conflicts

- [x] Updating entities with new attributes

- [ ] Creating versions of coredata model

- [ ] Light weight migration policy

- [ ] Heavy weight migration with mapping model

- [ ] Importing data from existing sql database

- [ ] Different persistent stores

- [ ] Performance tuning using faults

- [ ] Folder structure for coredata stack or related code across the project

- [x] Logging Coredata Queries

- [x] Debugging with 'DB Browser for SQLite'

- [ ] Testing Coredata related code

## Resources
Block diagram whichh explains how model changes saved in parent/child contexts
![Screenshot 2021-05-18 at 3 55 05 PM](https://user-images.githubusercontent.com/12964593/118635660-77cf2e80-b7f1-11eb-864e-906fe51aa022.png)

Supporting Codable with NSManagedObject classes
https://www.donnywals.com/using-codable-with-core-data-and-nsmanagedobject/

Observing managed object change notifications
https://www.donnywals.com/observing-changes-to-managed-objects-across-contexts-with-combine/

Using multiple managed object contexts in coredata
https://www.cocoanetics.com/2012/07/multi-context-coredata/

Unit of Work pattern
https://martinfowler.com/eaaCatalog/unitOfWork.html

Coredta Transactions
https://christiantietze.de/posts/2015/10/unit-of-work-core-data-transaction/#:~:text=Transactions%20and%20Rolling%20Back%20Changes%20in%20Core%20Data%20with%20UnitOfWork,-Oct%2012th%2C%202015&text=The%20Unit%20of%20Work%20pattern,changes%20and%20have%20them%20saved.

Coredata progressive migrations
https://kean.blog/post/core-data-progressive-migrations

Apple's earth quake sample project
https://developer.apple.com/documentation/coredata/loading_and_displaying_a_large_data_feed
