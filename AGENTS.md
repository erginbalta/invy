# AGENTS.md

## Project Overview

Project name: Invy

Invy is an ultra-simple, offline-first mobile inventory tracking application.

The goal is not to build ERP software.

The goal is to help individuals and small businesses track stock quantities with the least possible friction.

The application must work without internet.

No backend is required for MVP.

No login or register is required for MVP.

The user should be able to open the app, complete a short setup, add products, scan barcode/QR codes, and perform stock in / stock out operations.

---

## Core Product Principle

If the user needs training to use Invy, the product has failed.

Every screen must be simple, clean, and understandable within minutes.

Do not add unnecessary fields, flows, or enterprise features.

---

## MVP Scope

### Onboarding

On first launch:

* Ask usage type:

  * Personal
  * Business
* If Business is selected, ask business name.
* Save setup locally.
* Do not show onboarding again after completion.

---

### Product Management

Users must be able to:

* Create product
* Update product
* Soft delete product
* View product detail
* Search products
* Filter low-stock products

Product fields:

* id
* name
* barcode / generated code
* current stock
* minimum stock
* image path, optional
* created at
* updated at
* is deleted

Do not add price fields.

Do not add supplier fields in MVP.

Do not add accounting fields.

Do not add invoice fields.

---

### Stock Operations

Users must be able to:

* Scan barcode or QR
* If product exists:

  * Stock in
  * Stock out
* If product does not exist:

  * Create new product with name and starting stock
* View stock movement history

Stock movement fields:

* id
* product id
* type: IN, OUT, ADJUSTMENT
* quantity
* previous stock
* new stock
* created at
* note, optional

Stock cannot go below zero unless explicitly handled with a clear validation message.

---

### Barcode and QR

The app must support:

* Barcode scanning
* QR scanning
* Manual barcode/code input fallback
* Auto-generated internal code for products without barcode
* QR generation for products without barcode

Generated code format:

INVY-000001

The generated QR should encode this generated product code.

---

### Dashboard / Product List

The main screen should be the product list.

It should show:

* Total product count
* Low stock product count
* Search bar
* Product list cards
* Quick access to scan / product operation

Product cards should show only essential information:

* Product name
* Current stock
* Minimum stock
* Low stock indicator when applicable

---

### Out of Scope for MVP

Do not build:

* Backend
* Login
* Register
* Cloud sync
* Multi-user support
* Web dashboard
* Supplier module
* Purchase order
* Invoice
* Accounting
* CRM
* HR
* Payroll
* ERP features
* Multi-warehouse
* Roles and permissions
* Subscription system
* Online payment

---

## Future Modules

These are future features. Do not implement them in MVP.

* Supplier module
* Supplier WhatsApp/message body generation
* Backup and restore
* Cloud sync
* Multi-device support
* Web dashboard
* Multi-user support

---

## Technology Direction

Use:

* Flutter
* Dart
* Local database
* SQLite with sqflite or drift
* Barcode / QR scanning package
* QR generation package
* Local notification package only if needed for low-stock alerts

Preferred packages:

* sqflite or drift
* path_provider
* mobile_scanner
* qr_flutter
* image_picker, only for optional product image
* provider, riverpod, or bloc for state management

Keep state management simple.

Avoid unnecessary architecture complexity.

---

## Architecture

Use feature-based structure.

Recommended structure:

lib/
main.dart
app/
app.dart
theme/
router/
core/
constants/
utils/
widgets/
database/
app_database.dart
tables/
migrations/
features/
onboarding/
products/
stock_operations/
scanner/
settings/

Each feature may include:

* data
* models
* repositories
* services
* screens
* widgets

Do not create backend-like complexity inside the mobile app.

---

## UI / UX Direction

The UI must look premium, minimal, clean, and calm.

Avoid cheap-looking UI.

Avoid excessive colors, gradients, shadows, and icons.

Use a light color palette.

Recommended palette:

* Background: #F8F7F4
* Surface/Card: #FFFFFF
* Primary: #2F6B5F
* Primary Soft: #E3F1EC
* Text Primary: #1F2933
* Text Secondary: #6B7280
* Border: #E5E1DA
* Warning / Low Stock: #D97706
* Success / Stock In: #2E7D32
* Danger / Stock Out: #C2410C

Design style:

* Soft business app
* Rounded cards
* Large touch targets
* Clear typography
* Minimal forms
* No clutter
* No ERP-like screens

The app should feel simple but not amateur.

---

## Important Product Rules

* Product creation must be fast.
* Product operation must be faster than manual notebook tracking.
* Barcode/QR scanning must be central to the experience.
* Do not force optional information.
* Do not ask for price.
* Do not ask for supplier.
* Do not require internet.
* Do not require account creation.
* Do not overbuild.

---

## Development Rules

* Implement the project phase by phase.
* Keep code clean and readable.
* Add comments only where helpful.
* Avoid premature abstraction.
* Validate user inputs.
* Handle empty states.
* Handle scanner permission issues.
* Handle duplicate barcode/code cases.
* Keep all data local.
* Make the app runnable after each phase.

---

## Expected MVP Screens

1. Onboarding Screen
2. Product List Screen
3. Product Detail Screen
4. Add/Edit Product Screen
5. Product Operation Screen
6. Scanner Screen
7. Settings Screen

---

## Definition of Done

The MVP is done when:

* User can complete onboarding.
* User can add a product manually.
* User can scan barcode/QR.
* If scanned product exists, user can stock in/out.
* If scanned product does not exist, user can create it.
* User can see product list.
* User can search products.
* User can see low-stock products.
* User can see movement history.
* App works offline.
* App does not require login.
* App has a clean, premium, light UI.
