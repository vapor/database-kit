/// Adds conveniences for using URLs referencing database servers.
extension URL {
    /// If present, this specifies a database on database servers that support multiple databases.
    ///
    /// This property converts the URL's `path` property to a database name by removing the leading `/`
    /// and all data after trailing `/`.
    ///
    ///     URL(string: "/vapor_database/asdf")?.databaseName // "vapor_database"
    ///
    public var databaseName: String? {
        return path.split(separator: "/", omittingEmptySubsequences: true).first.flatMap(String.init)
    }
}
