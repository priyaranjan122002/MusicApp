
# Music Dataset Virtualization Challenge

A Flutter music library app designed to handle 50,000+ tracks with infinite scrolling, grouping, and search, using the Deezer API and LRCLIB.

## Features
- **Infinite Scroll**: Seemingly endless list of tracks (simulated via rotated search queries).
- **Sticky Headers**: Grouped by first letter (A-Z).
- **Search**: Real-time search with debounce.
- **Details & Lyrics**: View high-res album art and lyrics.
- **Offline Mode**: Explicit "NO INTERNET CONNECTION" handling.

## BLoC Flow Summary
### LibraryBloc
- **Events**: `LoadTracks`, `ScrollBottomReached`, `SearchTracks`.
- **States**: `LibraryLoading`, `LibraryLoaded` (list of tracks), `LibraryError`, `LibraryOffline`.
- **Logic**: Manages the list of tracks. When `ScrollBottomReached` is fired, it requests the next "page" from the repository.

### DetailsBloc
- **Events**: `LoadTrackDetails`.
- **States**: `DetailsLoading`, `DetailsLoaded`, `DetailsError`, `DetailsOffline`.
- **Logic**: Fetches track details from Deezer and lyrics from LRCLIB in parallel (or sequential if needed).

## Design Decisions
1. **Repository-based Virtualization**:  
   Instead of loading 50k items at once, the `TrackRepository` acts as a "Smart Seeder". It cycles through search queries ('a', 'b', ... 'z', 'pop'...) to simulate a massive dataset. This avoids API rate limits and memory spikes while providing a "50k+" feel.

2. **Native Sticky Headers**:  
   Strictly adhering to "No third-party virtualization packages", I used Flutter's `SliverMainAxisGroup` and `SliverPersistentHeader` to implement sticky headers. This provides native performance without external dependencies.

3. **Memory Optimization**:  
   Used `CachedNetworkImage` with `memCacheWidth: 100` for list items. This ensures that decoded images in memory are small thumbnails, preventing Out-Of-Memory (OOM) errors during long scrolls.

## Issue Faced + Fix
- **Issue**: Attempting to group 50,000 items in real-time on the UI thread caused dropped frames during the initial load or search.
- **Fix**: For this demo, I optimized the basic grouping to only run on the *loaded* chunk or relied on the natural order of the API (which returns results somewhat grouped). For a production app, I would move this logic to a background `Isolate`.

## What breaks at 100k?
At 100,000+ items, the simple `List<Track>` in memory (~20MB for objects) is stable, but:
1. **Search Performance**: Filtering a list of 100k items on the main thread will cause noticeable UI freeze (approx 100ms+ lag).
   - *Fix*: Move search logic to a separate `Isolate` or use `compute()`.
2. **Grouping Overhead**: Re-calculating the groups for the entire list on every `setState` or `Bloc` yield will become too slow.
   - *Fix*: Use a local database (SQLite/Drift) to handle sorting and grouping efficiently, only loading the *keys* or *visible items* into memory.

## How to Run
1. `flutter pub get`
2. `flutter run`

## Offline Handling
The app checks for connectivity before every API call. If offline, it immediately shows a "NO INTERNET CONNECTION" state in red.
