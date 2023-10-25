import WinUI

// IXamlMetadataProvider is a protocol that is used by the Xaml runtime to get metadata about types when
// parsing xaml files.
private var metadataProvider: XamlControlsXamlMetaDataProvider = .init()
extension PreviewApp: IXamlMetadataProvider {
    public func getXamlType(_ type: TypeName) throws -> IXamlType! {
        print("getXamlType: \(type.name)")
        return try metadataProvider.getXamlType(type)
    }

    public func getXamlType(_ fullName: String) throws -> IXamlType! {
        print("getXamlType: \(fullName)")
        return try metadataProvider.getXamlType(fullName)
    }
}
