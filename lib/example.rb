require 'treesl'

parser = TreeSL.define do
  root 'person'

  person 'title firstname lastname'
  person 'title lastname'
  person 'firstname lastname'

  title /^Mr|Mrs|Ms$/
  firstname 'propernoun'
  lastname 'propernoun'
  propernoun /^[A-Z][a-z]+/
end

p parser.match("Sam Jones") #=> {"firstname lastname"=>{"lastname"=>"Jones", "firstname"=>"Sam"}}
p parser.match("Mr Sam Jones") #=> {"title firstname lastname"=>{"title"=>"Mr", "lastname"=>"Jones", "firstname"=>"Sam"}}
p parser.match("Mr Jones") #=> {"title lastname"=>{"title"=>"Mr", "lastname"=>"Jones"}}
