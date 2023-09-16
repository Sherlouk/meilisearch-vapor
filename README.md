<p align="center">
  <img src="https://raw.githubusercontent.com/Sherlouk/meilisearch-vapor/main/.github/readme-logo.png" alt="meilisearch-vapor" width="543" height="200" />
</p>

<h1 align="center">Meilisearch for Vapor</h1>

<h4 align="center">
  <a href="https://github.com/meilisearch/meilisearch-swift">Meilisearch for Swift</a> |
  <a href="https://www.meilisearch.com/cloud?utm_campaign=oss&utm_source=github&utm_medium=meilisearch-vapor">Meilisearch Cloud</a> |
  <a href="https://discord.meilisearch.com">Discord</a> |
  <a href="https://www.meilisearch.com">Website</a>
</h4>

**Meilisearch Vapor** is a thin wrapper around the official Meilisearch for Swift API client, designed for compatibility with Vapor (a server-side Swift framework).

## 🔧 Installation

### With the Swift Package Manager <!-- omit in toc -->

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding **MeiliSearchVapor** as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/sherlouk/meilisearch-vapor.git", from: "0.1.0")
]
```

### Run Meilisearch <!-- omit in toc -->

There are many easy ways to [download and run a Meilisearch instance](https://docs.meilisearch.com/reference/features/installation.html#download-and-launch).

For example, using the `curl` command in your [Terminal](https://itconnect.uw.edu/learn/workshops/online-tutorials/web-publishing/what-is-a-terminal/):

```sh
#Install Meilisearch
curl -L https://install.meilisearch.com | sh

# Launch Meilisearch
./meilisearch --master-key=masterKey
```

NB: you can also download Meilisearch from **Homebrew** or **APT** or even run it using **Docker**.

## 🎬 Getting started

To do a simple insertion using the client, you can create a Swift script like this:

```swift
    import MeiliSearchVapor

    // in your Vapor startup: 
    func configure(app: Application) throws {
        app.meilisearch.configure(host: "http://localhost:7700")
    }
    
    // in your Vapor route:
    app.post("addDocuments") { req -> EventLoopFuture<String> in
        let promise = req.eventLoop.makePromise(of: String.self)
        
        struct Movie: Codable, Equatable {
            let id: Int
            let title: String
            let genres: [String]
        }
        
        let movies: [Movie] = [
            Movie(id: 1, title: "Carol", genres: ["Romance", "Drama"]),
            Movie(id: 2, title: "Wonder Woman", genres: ["Action", "Adventure"]),
            Movie(id: 3, title: "Life of Pi", genres: ["Adventure", "Drama"]),
            Movie(id: 4, title: "Mad Max: Fury Road", genres: ["Adventure", "Science Fiction"]),
            Movie(id: 5, title: "Moana", genres: ["Fantasy", "Action"]),
            Movie(id: 6, title: "Philadelphia", genres: ["Drama"])
        ]
        
        // An index is where the documents are stored.
        // The uid is the unique identifier to that index.
        let index = req.meilisearch.index("movies")
        
        // If the index 'movies' does not exist, Meilisearch creates it when you first add the documents.
        index.addDocuments(
            documents: movies,
            primaryKey: nil
        ) { result in
            switch result {
            case .success(let task):
                print(task) // => Task(uid: 0, status: "enqueued", ...)
                promise.succeed(String(describing: task))
            case .failure(let error):
                promise.fail(error)
            }
        }
        
        return promise.futureResult
    }
```

