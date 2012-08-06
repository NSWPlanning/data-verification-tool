ActiveRecord::Base.logger = Logger.new(STDOUT)

admin = User.new :email => 'admin@example.com', :password => 'password',
                 :password_confirmation => 'password'
admin.roles = [:admin]
admin.save!

[
  'Albury', 'Armidale Dumaresq', 'Ashfield', 'Auburn', 'Ballina', 'Balranald',
  'Bankstown', 'Bathurst Regional', 'Baulkham Hills', 'Bega Valley',
  'Bellingen', 'Berrigan', 'Blacktown', 'Bland', 'Blayney', 'Blue Mountains',
  'Bogan', 'Bombala', 'Boorowa', 'Botany Bay', 'Bourke', 'Brewarrina', 'Broken
  Hill', 'Burwood', 'Byron', 'Cabonne', 'Camden', 'Campbelltown', 'Canada Bay',
  'Canterbury', 'Carrathool', 'Central Darling', 'Cessnock', 'Clarence Valley',
  'Cobar', 'Coffs Harbour', 'Conargo', 'Coolamon', 'Cooma-Monaro', 'Coonamble',
  'Cootamundra', 'Corowa', 'Cowra', 'Deniliquin', 'Dubbo', 'Dungog',
  'Eurobodalla', 'Fairfield', 'Forbes', 'Gilgandra', 'Glen Innes Severn Shire',
  'Gloucester', 'Gosford', 'Goulburn Mulwaree', 'Great Lakes', 'Greater Hume',
  'Greater Taree', 'Griffith', 'Gundagai', 'Gunnedah', 'Guyra', 'Gwydir',
  'Harden', 'Hawkesbury', 'Hay', 'Holroyd', 'Hornsby', 'Hunters Hill',
  'Hurstville', 'Inverell', 'Jerilderie', 'Junee', 'Kempsey', 'Kiama',
  'Kogarah', 'Ku-Ring-Gai', 'Kyogle', 'Lachlan', 'Lake Macquarie', 'Lane Cove',
  'Leeton', 'Leichhardt', 'Lismore', 'Lithgow', 'Liverpool', 'Liverpool
  Plains', 'Lockhart', 'Maitland', 'Manly', 'Marrickville', 'Mid-Western
  Regional', 'Moree Plains', 'Mosman', 'Murray', 'Murrumbidgee',
  'Muswellbrook', 'Nambucca', 'Narrabri', 'Narrandera', 'Narromine',
  'Newcastle', 'North Sydney', 'Oberon', 'Orange', 'Palerang', 'Parkes',
  'Parramatta', 'Penrith', 'Pittwater', 'Port Macquarie-Hastings', 'Port
  Stephens', 'Queanbeyan City', 'Randwick', 'Richmond Valley', 'Rockdale',
  'Ryde', 'Shellharbour', 'Shoalhaven', 'Singleton', 'Snowy River',
  'Strathfield', 'Sutherland', 'Sydney', 'Tamworth Regional', 'Temora',
  'Tenterfield', 'Tumbarumba', 'Tumut', 'Tweed', 'Unincorporated', 'Upper
  Hunter', 'Upper Lachlan Shire', 'Uralla', 'Urana', 'Wagga Wagga', 'Wakool',
  'Walcha', 'Walgett', 'Warren', 'Warringah', 'Warrumbungle', 'Waverley',
  'Weddin', 'Wellington', 'Wentworth', 'Willoughby', 'Wingecarribee',
  'Wollondilly', 'Wollongong', 'Woollahra', 'Wyong', 'Yass Valley', 'Young'
].map do |local_government_area|
  LocalGovernmentArea.create! :name => local_government_area
end
