platform :ios, '8.0'

use_frameworks!
inhibit_all_warnings!


def import_pods
    pod 'WCDB'
end


target "WCDBTests" do
    import_pods

    target 'WCDBTestsTests' do
        inherit! :search_paths
    end
end