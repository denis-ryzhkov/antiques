while (<>) { $lines{ $_ } = 1 }
for ( sort keys %lines ) { print }