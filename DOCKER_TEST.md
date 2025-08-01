# Docker Testing Instructions

## Fixed Issue
The homepage table rendering issue in Docker has been resolved. The problem was that `req(municipal_data)` was halting execution when data was NULL during progressive loading.

## Changes Made
1. **Replaced blocking `req()` with proper reactive handling** in `R/mod_home_table.R`
2. **Added loading state display** for better user experience
3. **Updated server call** to pass reactive reference instead of static value
4. **Implemented graceful fallback** when data is not yet available

## Testing Steps

### Build and Run Docker Container

```bash
# Build the Docker image
docker build -f prod.Dockerfile -t peskas-timor-portal .

# Run the container
docker run -p 3838:3838 peskas-timor-portal
```

### What to Test

1. **Homepage Loading**
   - Navigate to `http://localhost:3838`
   - Check that the homepage loads without errors
   - Verify that the table at the bottom shows "Loading municipal data..." initially
   - Confirm the table populates with actual data after progressive loading completes

2. **Progressive Loading Behavior**
   - The donut charts should load first (essential data)
   - The table should show loading state initially
   - All components should eventually populate with real data

3. **Error Handling**
   - No JavaScript errors in browser console
   - No R errors in Docker logs
   - Graceful degradation if data loading fails

### Expected Behavior

- **Initial Load**: Table shows "Loading municipal data..." message
- **After Data Load**: Table displays municipal statistics with proper formatting
- **No Blocking**: UI remains responsive throughout loading process
- **Error Recovery**: If data fails to load, table shows appropriate fallback

### Docker Logs

Monitor Docker logs for any errors:
```bash
docker logs <container_id>
```

You should see:
- "Starting progressive data loading"
- "All data loaded successfully" (or partial loading messages)
- No error messages related to table rendering

## Fixed Architecture

The progressive loading now works correctly in Docker:

1. `shared_data$municipal_aggregated` starts as NULL
2. Table module receives reactive reference, not static value
3. Module handles NULL data gracefully with loading state
4. Data populates asynchronously without blocking UI
5. Table updates automatically when data becomes available

The Docker deployment should now work without the homepage table rendering issue.