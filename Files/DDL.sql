create type account_type_bme as enum('savings', 'current', 'recurring', 'fixed');
create type gender_type_bme as enum('male', 'female');
create type transaction_type_bme as enum('debit', 'credit');
create type transaction_method_bme as enum('cash', 'cheque', 'dd');

create table customer_bme(
	fname varchar(30) not null,
	lname varchar(30) not null,
	username char(10) primary key,
	hash_password char(32) not null,
	dob date not null,
	email varchar(30),
	gender gender_type_bme not null,
	contact char(10) not null,
	address char(50) not null
);

create table employee_bme(
	employee_id char(6) primary key,
	hash_password char(32) not null
);

create table branch_bme(
	branch_id char(5) primary key,
	address varchar(50) not null,
	IFSC char(10) not null,
	contact char(10) not null
);

create table account_type_info_bme(
	type_name account_type_bme primary key,
	minimum_balance numeric(10, 2) not null,
	withdraw_limit numeric(10, 2) not null,
	check (minimum_balance >= 0),
	check (withdraw_limit >= 0)
);

create table account_bme(
	account_number char(10) primary key,
	type account_type_bme not null,
	current_balance numeric(10, 2) not null,
	first_owner_id char(10) references customer_bme(username) on delete cascade,
	second_owner_id char(10) references customer_bme(username) on delete cascade,
	branch_id char(5) references branch_bme(branch_id),
	opening_date date not null
	check (first_owner_id <> '0000000000')
);

create table transaction_bme(
	transaction_id integer not null,
	transaction_type transaction_type_bme not null,
	transaction_method transaction_method_bme not null,
	transaction_date date not null,
	account_number char(10) references account_bme(account_number),
	amount numeric(10, 2) not null,
	remarks varchar(100),
	resulting_balance numeric(10, 2) not null,
	check (amount > 0),
	check (transaction_id > 0),
	primary key (account_number, transaction_id)
);

create table transfer_bme(
	transfer_id integer not null,
	sender_account_number char(10) references account_bme(account_number);
	receiver_account_number char(10) references account_bme(account_number);
	sender_resulting_balance numeric(10, 2) not null,
	receiver_resulting_balance numeric(10, 2) not null,
	amount numeric(10, 2) not null,
	transfer_date date not null,
	remarks varchar(100),
	primary key (sender_account_number, receiver_account_number, transfer_id),
	check (amount > 0),
	check (transfer_id > 0)
);

create table cheque_book_bme(
	account_number char(10) references account_bme(account_number),
	cheque_book_id integer not null,
	cheque_count integer not null,
	date_of_issue date not null,
	issuing_branch char(10) references branch_bme(branch_id),
	primary key (account_number, cheque_book_id)
);

create table demand_draft_bme(
	account_number char(10) references account_bme(account_number),
	draft_id integer not null,
	date_of_issue date not null,
	payee_name varchar(50) not null,
	amount numeric(10, 2) not null,
	issuing_branch char(10) references branch_bme(branch_id),
	resulting_balance numeric(10, 2) not null,
	check (amount > 0),
	primary key (account_number, draft_id)
);

create table debit_card_bme(
	account_number char(10) references account_bme(account_number),
	card_number varchar(16) not null,
	expiry_date date not null,
	issuing_branch char(10) references branch_bme(branch_id),
	cvv_code char(3) not null,
	hash_password char(32) not null,
	unique (card_number),
	primary key (account_number)
);

create table utility_bill(
	account_number char(10) references account_bme(account_number),
	bill_id varchar(10) not null,
	bill_amount numeric(10, 2) not null,
	bill_type varchar(10) not null,
	paid_to varchar(10) not null,
	resulting_balance numeric(10, 2) not null
);