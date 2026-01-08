# The guideline of writing SQL query
- write column comments in INSERT statements
```sql
-- Good practice: column comments
INSERT INTO users (
    id,      
    name,    
    email    
)
VALUES (
1,                  -- id
'John',             -- name
'john@example.com'  -- email
);

```
