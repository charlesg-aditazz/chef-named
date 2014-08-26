include_recipe 'apt'


# install bind packages on ubuntu
"bind,bindutils,nscd".split(',').each do |package_name|
  package package_name
end
