# Repository Pattern

## Pattern Type
**Enterprise Application Pattern**

## Intent

Mediates between the domain and data mapping layers using a collection-like interface for accessing domain objects. The Repository pattern encapsulates the logic required to access data sources and provides a more object-oriented view of the persistence layer.

## Problem

Direct database access from business logic leads to several issues:
- Business logic becomes tightly coupled to data access implementation
- Difficult to unit test business logic without a database
- Data access code is duplicated across the application
- Hard to switch between different data sources
- Domain model gets polluted with data access concerns

### Common Scenarios:
- CRUD operations on domain entities
- Complex query logic scattered across the application
- Need to abstract data source (database, API, file system, cache)
- Testing business logic without database dependencies
- Implementing different storage strategies (SQL, NoSQL, in-memory)

## Solution Structure

```
<<interface>> IRepository<T>
  + findById(id): T
  + findAll(): List<T>
  + save(entity: T): T
  + delete(id): void

ConcreteRepository<T>
  - dataSource: DataSource
  + findById(id): T
  + findAll(): List<T>
  + save(entity: T): T
  + delete(id): void

DomainService
  - repository: IRepository<T>
  + businessOperation()
```

## Implementation in Java

### Basic Example: User Repository

```java
public class User {
    private Long id;
    private String username;
    private String email;
    private LocalDateTime createdAt;

    public User(Long id, String username, String email, LocalDateTime createdAt) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.createdAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "User{id=" + id + ", username='" + username + "', email='" + email + "'}";
    }
}

public interface UserRepository {
    Optional<User> findById(Long id);
    List<User> findAll();
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    User save(User user);
    void delete(Long id);
    boolean exists(Long id);
}

public class InMemoryUserRepository implements UserRepository {
    private final Map<Long, User> storage = new ConcurrentHashMap<>();
    private final AtomicLong idGenerator = new AtomicLong(1);

    @Override
    public Optional<User> findById(Long id) {
        return Optional.ofNullable(storage.get(id));
    }

    @Override
    public List<User> findAll() {
        return new ArrayList<>(storage.values());
    }

    @Override
    public Optional<User> findByUsername(String username) {
        return storage.values().stream()
                .filter(user -> user.getUsername().equals(username))
                .findFirst();
    }

    @Override
    public Optional<User> findByEmail(String email) {
        return storage.values().stream()
                .filter(user -> user.getEmail().equals(email))
                .findFirst();
    }

    @Override
    public User save(User user) {
        if (user.getId() == null) {
            user.setId(idGenerator.getAndIncrement());
            user.setCreatedAt(LocalDateTime.now());
        }
        storage.put(user.getId(), user);
        return user;
    }

    @Override
    public void delete(Long id) {
        storage.remove(id);
    }

    @Override
    public boolean exists(Long id) {
        return storage.containsKey(id);
    }
}

public class DatabaseUserRepository implements UserRepository {
    private final DataSource dataSource;

    public DatabaseUserRepository(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public Optional<User> findById(Long id) {
        String sql = "SELECT id, username, email, created_at FROM users WHERE id = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            throw new RepositoryException("Error finding user by id: " + id, e);
        }

        return Optional.empty();
    }

    @Override
    public List<User> findAll() {
        String sql = "SELECT id, username, email, created_at FROM users";
        List<User> users = new ArrayList<>();

        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            throw new RepositoryException("Error finding all users", e);
        }

        return users;
    }

    @Override
    public Optional<User> findByUsername(String username) {
        String sql = "SELECT id, username, email, created_at FROM users WHERE username = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            throw new RepositoryException("Error finding user by username: " + username, e);
        }

        return Optional.empty();
    }

    @Override
    public Optional<User> findByEmail(String email) {
        String sql = "SELECT id, username, email, created_at FROM users WHERE email = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            throw new RepositoryException("Error finding user by email: " + email, e);
        }

        return Optional.empty();
    }

    @Override
    public User save(User user) {
        if (user.getId() == null) {
            return insert(user);
        } else {
            return update(user);
        }
    }

    private User insert(User user) {
        String sql = "INSERT INTO users (username, email, created_at) VALUES (?, ?, ?)";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new RepositoryException("Creating user failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    user.setId(generatedKeys.getLong(1));
                    user.setCreatedAt(LocalDateTime.now());
                } else {
                    throw new RepositoryException("Creating user failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            throw new RepositoryException("Error inserting user", e);
        }

        return user;
    }

    private User update(User user) {
        String sql = "UPDATE users SET username = ?, email = ? WHERE id = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setLong(3, user.getId());

            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new RepositoryException("Updating user failed, user not found: " + user.getId());
            }
        } catch (SQLException e) {
            throw new RepositoryException("Error updating user", e);
        }

        return user;
    }

    @Override
    public void delete(Long id) {
        String sql = "DELETE FROM users WHERE id = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, id);
            stmt.executeUpdate();

        } catch (SQLException e) {
            throw new RepositoryException("Error deleting user: " + id, e);
        }
    }

    @Override
    public boolean exists(Long id) {
        String sql = "SELECT COUNT(*) FROM users WHERE id = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            throw new RepositoryException("Error checking user existence: " + id, e);
        }

        return false;
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        return new User(
                rs.getLong("id"),
                rs.getString("username"),
                rs.getString("email"),
                rs.getTimestamp("created_at").toLocalDateTime()
        );
    }
}

public class RepositoryException extends RuntimeException {
    public RepositoryException(String message) {
        super(message);
    }

    public RepositoryException(String message, Throwable cause) {
        super(message, cause);
    }
}

public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User registerUser(String username, String email) {
        if (userRepository.findByUsername(username).isPresent()) {
            throw new IllegalArgumentException("Username already exists: " + username);
        }

        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException("Email already exists: " + email);
        }

        User newUser = new User(null, username, email, null);
        return userRepository.save(newUser);
    }

    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    public Optional<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public User updateUserEmail(Long userId, String newEmail) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        if (userRepository.findByEmail(newEmail)
                .filter(u -> !u.getId().equals(userId))
                .isPresent()) {
            throw new IllegalArgumentException("Email already in use: " + newEmail);
        }

        user.setEmail(newEmail);
        return userRepository.save(user);
    }

    public void deleteUser(Long userId) {
        if (!userRepository.exists(userId)) {
            throw new IllegalArgumentException("User not found: " + userId);
        }

        userRepository.delete(userId);
    }
}

public class Main {
    public static void main(String[] args) {
        UserRepository repository = new InMemoryUserRepository();
        UserService userService = new UserService(repository);

        System.out.println("=== User Registration Demo ===\n");

        User user1 = userService.registerUser("john_doe", "john@example.com");
        System.out.println("Registered: " + user1);

        User user2 = userService.registerUser("jane_smith", "jane@example.com");
        System.out.println("Registered: " + user2);

        User user3 = userService.registerUser("bob_jones", "bob@example.com");
        System.out.println("Registered: " + user3);

        System.out.println("\n=== All Users ===\n");
        userService.getAllUsers().forEach(System.out::println);

        System.out.println("\n=== Find User by ID ===\n");
        userService.getUserById(1L).ifPresent(System.out::println);

        System.out.println("\n=== Find User by Username ===\n");
        userService.getUserByUsername("jane_smith").ifPresent(System.out::println);

        System.out.println("\n=== Update Email ===\n");
        User updated = userService.updateUserEmail(1L, "john.doe@newdomain.com");
        System.out.println("Updated: " + updated);

        System.out.println("\n=== Delete User ===\n");
        userService.deleteUser(3L);
        System.out.println("User deleted. Remaining users:");
        userService.getAllUsers().forEach(System.out::println);

        System.out.println("\n=== Validation Tests ===\n");

        try {
            userService.registerUser("john_doe", "duplicate@example.com");
        } catch (IllegalArgumentException e) {
            System.out.println("Error: " + e.getMessage());
        }

        try {
            userService.updateUserEmail(1L, "jane@example.com");
        } catch (IllegalArgumentException e) {
            System.out.println("Error: " + e.getMessage());
        }

        try {
            userService.deleteUser(999L);
        } catch (IllegalArgumentException e) {
            System.out.println("Error: " + e.getMessage());
        }
    }
}
```

### Output:
```
=== User Registration Demo ===

Registered: User{id=1, username='john_doe', email='john@example.com'}
Registered: User{id=2, username='jane_smith', email='jane@example.com'}
Registered: User{id=3, username='bob_jones', email='bob@example.com'}

=== All Users ===

User{id=1, username='john_doe', email='john@example.com'}
User{id=2, username='jane_smith', email='jane@example.com'}
User{id=3, username='bob_jones', email='bob@example.com'}

=== Find User by ID ===

User{id=1, username='john_doe', email='john@example.com'}

=== Find User by Username ===

User{id=2, username='jane_smith', email='jane@example.com'}

=== Update Email ===

Updated: User{id=1, username='john_doe', email='john.doe@newdomain.com'}

=== Delete User ===

User deleted. Remaining users:
User{id=1, username='john_doe', email='john.doe@newdomain.com'}
User{id=2, username='jane_smith', email='jane@example.com'}

=== Validation Tests ===

Error: Username already exists: john_doe
Error: Email already in use: jane@example.com
Error: User not found: 999
```

## Advanced Example: Generic Repository with Specification Pattern

```java
public interface Specification<T> {
    boolean isSatisfiedBy(T entity);
}

public interface Repository<T, ID> {
    Optional<T> findById(ID id);
    List<T> findAll();
    List<T> findBySpecification(Specification<T> specification);
    T save(T entity);
    void delete(ID id);
    boolean exists(ID id);
    long count();
}

public abstract class InMemoryRepository<T, ID> implements Repository<T, ID> {
    protected final Map<ID, T> storage = new ConcurrentHashMap<>();

    protected abstract ID getId(T entity);
    protected abstract void setId(T entity, ID id);
    protected abstract ID generateId();

    @Override
    public Optional<T> findById(ID id) {
        return Optional.ofNullable(storage.get(id));
    }

    @Override
    public List<T> findAll() {
        return new ArrayList<>(storage.values());
    }

    @Override
    public List<T> findBySpecification(Specification<T> specification) {
        return storage.values().stream()
                .filter(specification::isSatisfiedBy)
                .collect(Collectors.toList());
    }

    @Override
    public T save(T entity) {
        ID id = getId(entity);
        if (id == null) {
            id = generateId();
            setId(entity, id);
        }
        storage.put(id, entity);
        return entity;
    }

    @Override
    public void delete(ID id) {
        storage.remove(id);
    }

    @Override
    public boolean exists(ID id) {
        return storage.containsKey(id);
    }

    @Override
    public long count() {
        return storage.size();
    }
}

public class Product {
    private Long id;
    private String name;
    private String category;
    private double price;
    private int stock;

    public Product(Long id, String name, String category, double price, int stock) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.price = price;
        this.stock = stock;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getStock() {
        return stock;
    }

    public void setStock(int stock) {
        this.stock = stock;
    }

    @Override
    public String toString() {
        return "Product{id=" + id + ", name='" + name + "', category='" + category +
                "', price=" + price + ", stock=" + stock + "}";
    }
}

public class ProductRepository extends InMemoryRepository<Product, Long> {
    private final AtomicLong idGenerator = new AtomicLong(1);

    @Override
    protected Long getId(Product entity) {
        return entity.getId();
    }

    @Override
    protected void setId(Product entity, Long id) {
        entity.setId(id);
    }

    @Override
    protected Long generateId() {
        return idGenerator.getAndIncrement();
    }

    public List<Product> findByCategory(String category) {
        return findBySpecification(product -> product.getCategory().equals(category));
    }

    public List<Product> findByPriceRange(double minPrice, double maxPrice) {
        return findBySpecification(product ->
                product.getPrice() >= minPrice && product.getPrice() <= maxPrice
        );
    }

    public List<Product> findInStock() {
        return findBySpecification(product -> product.getStock() > 0);
    }

    public List<Product> findExpensiveProducts(double threshold) {
        return findBySpecification(product -> product.getPrice() > threshold);
    }
}

public class ProductService {
    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    public Product addProduct(String name, String category, double price, int stock) {
        Product product = new Product(null, name, category, price, stock);
        return productRepository.save(product);
    }

    public List<Product> getProductsByCategory(String category) {
        return productRepository.findByCategory(category);
    }

    public List<Product> getAffordableProducts(double maxPrice) {
        return productRepository.findByPriceRange(0, maxPrice);
    }

    public List<Product> getAvailableProducts() {
        return productRepository.findInStock();
    }

    public boolean purchaseProduct(Long productId, int quantity) {
        Optional<Product> productOpt = productRepository.findById(productId);

        if (productOpt.isEmpty()) {
            return false;
        }

        Product product = productOpt.get();

        if (product.getStock() < quantity) {
            return false;
        }

        product.setStock(product.getStock() - quantity);
        productRepository.save(product);
        return true;
    }

    public void restockProduct(Long productId, int quantity) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found: " + productId));

        product.setStock(product.getStock() + quantity);
        productRepository.save(product);
    }
}

public class RepositoryDemo {
    public static void main(String[] args) {
        ProductRepository repository = new ProductRepository();
        ProductService service = new ProductService(repository);

        System.out.println("=== Adding Products ===\n");

        service.addProduct("Laptop", "Electronics", 999.99, 10);
        service.addProduct("Mouse", "Electronics", 29.99, 50);
        service.addProduct("Desk", "Furniture", 299.99, 5);
        service.addProduct("Chair", "Furniture", 199.99, 8);
        service.addProduct("Monitor", "Electronics", 399.99, 0);

        System.out.println("Total products: " + repository.count());

        System.out.println("\n=== Electronics Category ===\n");
        service.getProductsByCategory("Electronics").forEach(System.out::println);

        System.out.println("\n=== Affordable Products (under $300) ===\n");
        service.getAffordableProducts(300).forEach(System.out::println);

        System.out.println("\n=== Available Products (in stock) ===\n");
        service.getAvailableProducts().forEach(System.out::println);

        System.out.println("\n=== Purchase Product ===\n");
        boolean success = service.purchaseProduct(1L, 2);
        System.out.println("Purchase successful: " + success);

        repository.findById(1L).ifPresent(p ->
                System.out.println("Updated stock: " + p)
        );

        System.out.println("\n=== Restock Product ===\n");
        service.restockProduct(5L, 15);
        repository.findById(5L).ifPresent(p ->
                System.out.println("Restocked: " + p)
        );

        System.out.println("\n=== Expensive Products (over $300) ===\n");
        repository.findExpensiveProducts(300).forEach(System.out::println);
    }
}
```

## Key Components

1. **Repository Interface** - Defines contract for data access operations
2. **Concrete Repository** - Implements data access logic for specific entity
3. **Domain Entity** - Business object that the repository manages
4. **Domain Service** - Uses repository to perform business operations

## Advantages

✅ **Separation of Concerns** - Isolates data access logic from business logic
✅ **Testability** - Easy to mock repositories for unit testing
✅ **Centralized Data Access** - Single place for data operations
✅ **Flexibility** - Easy to switch data sources without changing business logic
✅ **Query Encapsulation** - Complex queries are hidden behind simple methods
✅ **DRY Principle** - Eliminates duplicate data access code

## Disadvantages

❌ **Abstraction Overhead** - Adds additional layer of abstraction
❌ **Learning Curve** - Team must understand the pattern
❌ **Over-abstraction Risk** - Can become too generic and lose clarity
❌ **Performance Concerns** - May not be optimal for complex queries
❌ **Leaky Abstraction** - Database concepts may leak through interface

## When to Use

Use Repository Pattern when:
- You need to abstract data access from business logic
- You want to centralize data access logic
- You need to support multiple data sources
- You want to improve testability of business logic
- You're implementing Domain-Driven Design (DDD)
- You have complex query logic that needs encapsulation

## When NOT to Use

Avoid Repository Pattern when:
- Application is very simple with minimal data access
- Direct ORM usage is sufficient
- Performance is critical and abstraction adds overhead
- Team is unfamiliar with the pattern and time is limited
- You're using a framework that already provides repository pattern (e.g., Spring Data JPA)

## Comparison with Similar Patterns

### Repository vs DAO (Data Access Object)
- **Repository**: Domain-centric, collection-like interface, part of domain layer
- **DAO**: Data-centric, CRUD-focused, part of infrastructure layer

### Repository vs Active Record
- **Repository**: Separates domain objects from persistence logic
- **Active Record**: Domain objects contain their own persistence logic

### Repository vs Service Layer
- **Repository**: Focused on data access and persistence
- **Service Layer**: Focused on business logic and workflow orchestration

## Real-World Examples

1. **Spring Data JPA** - Provides repository pattern implementation
2. **Entity Framework (C#)** - Repository pattern over database context
3. **Doctrine ORM (PHP)** - Repository classes for entities
4. **Hibernate** - Often used with repository pattern
5. **MongoDB repositories** - NoSQL data access abstraction

## Related Patterns

- **Unit of Work** - Tracks changes to objects and commits them together
- **Data Mapper** - Maps between objects and database tables
- **Query Object** - Encapsulates database queries
- **Specification** - Defines business rules for selecting objects
- **Factory Method** - Can create repository instances

## Best Practices

1. **Keep repositories focused** on single entity or aggregate root
2. **Return domain objects**, not DTOs or database records
3. **Use meaningful method names** that reflect business intent
4. **Don't expose IQueryable/Criteria** outside repository
5. **Consider generic base repository** for common operations
6. **Implement repository per aggregate** in DDD
7. **Use dependency injection** to provide repositories
8. **Don't let repositories become fat** - complex logic belongs in services
9. **Use specifications** for complex query logic
10. **Consider async methods** for I/O-bound operations

## Modern Java Implementation with Spring Data

```java
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);

    @Query("SELECT u FROM User u WHERE u.createdAt > :date")
    List<User> findRecentUsers(@Param("date") LocalDateTime date);

    @Query("SELECT u FROM User u WHERE u.email LIKE %:domain")
    List<User> findByEmailDomain(@Param("domain") String domain);
}

@Service
public class UserService {
    private final UserRepository userRepository;

    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User registerUser(String username, String email) {
        if (userRepository.findByUsername(username).isPresent()) {
            throw new IllegalArgumentException("Username already exists");
        }

        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setCreatedAt(LocalDateTime.now());

        return userRepository.save(user);
    }

    public List<User> getRecentUsers(int days) {
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(days);
        return userRepository.findRecentUsers(cutoffDate);
    }
}
```

## Unit Testing with Repository Pattern

```java
public class UserServiceTest {
    private UserService userService;
    private UserRepository mockRepository;

    @Before
    public void setUp() {
        mockRepository = mock(UserRepository.class);
        userService = new UserService(mockRepository);
    }

    @Test
    public void testRegisterUser_Success() {
        String username = "testuser";
        String email = "test@example.com";

        when(mockRepository.findByUsername(username)).thenReturn(Optional.empty());
        when(mockRepository.findByEmail(email)).thenReturn(Optional.empty());
        when(mockRepository.save(any(User.class))).thenAnswer(i -> i.getArgument(0));

        User result = userService.registerUser(username, email);

        assertNotNull(result);
        assertEquals(username, result.getUsername());
        assertEquals(email, result.getEmail());

        verify(mockRepository).save(any(User.class));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRegisterUser_DuplicateUsername() {
        String username = "existing";
        String email = "test@example.com";

        when(mockRepository.findByUsername(username))
                .thenReturn(Optional.of(new User(1L, username, "old@example.com", null)));

        userService.registerUser(username, email);
    }
}
```
