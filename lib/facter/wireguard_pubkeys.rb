Facter.add(:wireguard_pubkeys) do
  confine do
    File.directory?('/etc/wireguard/')
  end
  setcode do
    hash = {}
    Dir.glob('/etc/wireguard/*.pub').each do |file|
      filename = file.split('/')[3].split('.')[0]
      content = File.read(file)
      hash[filename] = content.chomp
    end
    hash
  end
end
