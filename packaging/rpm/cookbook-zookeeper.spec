Name: cookbook-zookeeper
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: Apache zookeeper cookbook to install and configure it in redborder environments

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-zookeeper
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/zookeeper
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/zookeeper/
chmod -R 0755 %{buildroot}/var/chef/cookbooks/zookeeper
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/zookeeper/README.md

%pre

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload zookeeper'
  ;;
esac

%files
%defattr(0755,root,root)
/var/chef/cookbooks/zookeeper
%defattr(0644,root,root)
/var/chef/cookbooks/zookeeper/README.md

%doc

%changelog
* Fri Jan 07 2022 David Vanhoucke <dvanhoucke@redborder.com> - 1.0.1-1
- change register to consul
* Tue Oct 18 2016 Alberto Rodríguez <arodriguez@redborder.com> - 1.0.0-1
- first spec version
