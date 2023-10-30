import WinUI

// IXamlMetadataProvider is a protocol that is used by the Xaml runtime to get metadata about types when
// parsing xaml files.
private var metadataProvider: XamlControlsXamlMetaDataProvider = .init()
extension PreviewApp: IXamlMetadataProvider {
    public func getXamlType(_ type: TypeName) throws -> IXamlType! {
        try metadataProvider.getXamlType(type)
    }

    public func getXamlType(_ fullName: String) throws -> IXamlType! {
        try metadataProvider.getXamlType(fullName)
    }
}
