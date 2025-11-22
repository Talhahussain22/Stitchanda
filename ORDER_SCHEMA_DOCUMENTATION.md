# Order Schema Documentation

## Overview
The order system supports multiple sub-orders within a single order, matching the structure from the create order page.

## Models

### 1. OrderModel (`lib/models/order_model.dart`)
Main order container with basic details.

**Fields:**
- `id` (String): Unique order identifier (e.g., "ORD001")
- `tailorName` (String): Name of the tailor
- `tailorArea` (String): Tailor's location/area
- `tailorId` (String?): Optional reference to tailor document
- `orderDetails` (List<OrderDetailsModel>): List of sub-orders
- `totalPrice` (int): Sum of all sub-order prices
- `deadline` (DateTime): Expected completion date
- `orderDate` (DateTime): When the order was placed
- `status` (String): "In Progress" or "Completed"
- `deliveredDate` (DateTime?): When the order was delivered (if completed)
- `customerId` (String?): Optional reference to customer document

**Computed Properties:**
- `items` - List of item type names (for backward compatibility)
- `itemCount` - Total number of sub-orders
- `isInProgress` - Boolean check if status is "In Progress"
- `isCompleted` - Boolean check if status is "Completed"
- `isOverdue` - Boolean check if deadline passed but not completed
- `daysUntilDeadline` - Days remaining (negative if overdue)

**Methods:**
- `fromJson()` - Create from Firestore document
- `toJson()` - Convert to Firestore document
- `copyWith()` - Create modified copy

---

### 2. OrderDetailsModel (`lib/models/order_details_model.dart`)
Individual sub-order within a main order.

**Fields:**
- `id` (String): Unique sub-order identifier (e.g., "OD001")
- `itemType` (String): Type of item (e.g., "Shirt", "Trouser", "Kurta")
- `clothType` (String): Material type (e.g., "Lawn", "Cotton", "Silk")
- `price` (int): Price for this specific item
- `description` (String?): Optional additional details
- `measurements` (String?): Optional measurement data
- `createdAt` (DateTime): When this sub-order was added

**Methods:**
- `fromJson()` - Create from Firestore document
- `toJson()` - Convert to Firestore document
- `copyWith()` - Create modified copy

---

## Example Data Structure

```dart
OrderModel(
  id: 'ORD001',
  tailorName: 'Laiba Majeed',
  tailorArea: 'Federal B Area',
  orderDetails: [
    OrderDetailsModel(
      id: 'OD001',
      itemType: '3-Piece Suit',
      clothType: 'Lawn',
      price: 5000,
      description: 'Traditional embroidered suit',
    ),
    OrderDetailsModel(
      id: 'OD002',
      itemType: 'Sherwani',
      clothType: 'Silk',
      price: 3500,
      description: 'Wedding sherwani with golden work',
    ),
  ],
  totalPrice: 8500, // Sum of all orderDetails prices
  deadline: DateTime(...),
  orderDate: DateTime(...),
  status: 'In Progress',
)
```

## Firestore Structure (Recommended)

```
orders (collection)
  ├─ ORD001 (document)
  │   ├─ id: "ORD001"
  │   ├─ tailorName: "Laiba Majeed"
  │   ├─ tailorArea: "Federal B Area"
  │   ├─ tailorId: "tailor_123"
  │   ├─ customerId: "customer_456"
  │   ├─ totalPrice: 8500
  │   ├─ deadline: Timestamp
  │   ├─ orderDate: Timestamp
  │   ├─ status: "In Progress"
  │   ├─ deliveredDate: null
  │   └─ orderDetails: [
  │       {
  │         id: "OD001",
  │         itemType: "3-Piece Suit",
  │         clothType: "Lawn",
  │         price: 5000,
  │         description: "Traditional embroidered suit",
  │         createdAt: Timestamp
  │       },
  │       {
  │         id: "OD002",
  │         itemType: "Sherwani",
  │         clothType: "Silk",
  │         price: 3500,
  │         description: "Wedding sherwani with golden work",
  │         createdAt: Timestamp
  │       }
  │     ]
```

## Usage in UI

### Orders Page
- Shows list of orders with summary (tailor, item count, total price)
- Tapping an order opens detailed view
- Detailed view shows all sub-orders with individual prices, cloth types, and descriptions
- Filters orders into "In Progress" and "Completed" tabs

### Create Order Page
- Builds list of OrderDetailsModel as user adds items
- Calculates totalPrice by summing all orderDetails prices
- Creates OrderModel with the orderDetails list when confirming

## Benefits of This Structure

1. **Scalability**: Each order can have unlimited sub-orders
2. **Detailed Tracking**: Each item has its own price, material, and description
3. **Easy Calculations**: Total price computed from sub-orders
4. **Firestore Ready**: Direct JSON serialization for database
5. **Backward Compatible**: `items` getter provides simple string list if needed
6. **Type Safe**: Strong typing prevents data inconsistencies

