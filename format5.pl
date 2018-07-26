use warnings;
use Data::Dumper qw(Dumper);
#use Spreadsheet::WriteExcel;

open(FL,"$ARGV[0]") or die "$!";

$count=1;

while($l=<FL>) {
    chomp($l);
    @tmp=split(/\t/,$l);

    $filetab=$tmp[0];
    $coord=$tmp[1];
    $index=$tmp[2];
    $ref=$tmp[3];
    $type=$tmp[4];
    $mut=$tmp[5];
    $snp = join ">",$ref,$mut;
    #    $subst=$tmp[11];
    @st=split(/\(/,$tmp[11]);
    $subst=$st[0];
    #need white space after freq
    $freq=join("",$tmp[9]," ");
    $gene_name=$tmp[13];
    $gene=$tmp[12];
    # IR is the antibiotic
    $IR=$tmp[17];
    $c=1;    
    if ($gene_name ne "GeneName") {

	@temp=split('_',$filetab);
	$ID=$temp[0];	

	
	# GeneName exists
	if ($gene_name ne " ") {  

	    # Subst exists -> use Subst
	    if ($subst ne " ") {
		
		if ($freq < 75) {
		    #remove white space from subst
		    chop($subst);
		    $subst = join(":",$subst,$freq);
		}
			
		push( @{ $rows{$ID}{$gene_name} }, $subst);
		
		$found{$gene_name}++;
		$a=++$c{$ID};
		
		push (@IR,$IR);
		$IR{$IR}+=1;
		++$count;
		# Subst does NOT exist -> use coordinate
	    }elsif($subst eq " ") {
		#		$gene_name="UNK";
		#		print "$index $mut\n";
		if ($index > 0) {
		    push @string, $mut;
		}else{
		    $ncoord=join("-",$coord, $mut);
		 }
#		print "@string\n";		
		$size= scalar @string;
		
		 #		print "$size\n";
		# size > 0 means that there is a peptide insertion
		if ($size > 0) {
		    $ncoord=join("", @string);
		}else{
		    $ncoord=join("-",$coord, $mut);
		}
		if ($freq<75) {
		    $ncoord=join("",$ncoord,$freq);
		}
				
#		@string=();
#		$ncoord=join("-",$coord, $mut);
		push( @{ $rows{$ID}{$gene_name} }, $ncoord);
		
		$found{$gene_name}++;
		$c++;
		@string=();
	    }

	    # GeneName does NOT exist 
	}elsif($gene_name eq " ") {

	    # Gene exists -> use Gene
	    if ($gene ne " ") {
		
		$gene_name=$gene;
		
	
		# Subst exists
		if ($subst ne " ") {

		    if ($freq < 75) {
			#remove white space from subst
			chop($subst);
			$subst = join(":",$subst,$freq);
		    }
		    
		    
		    push( @{ $rows{$ID}{$gene_name} }, $subst);
		
		    $found{$gene_name}++;
		    # Subst does NOT exist
		}elsif($subst eq " ") {
		    $ncoord=join("-",$coord, $mut);

		    if ($freq<75) {
			$ncoord=join("",$ncoord,$freq);
		    }
		    
		    push( @{ $rows{$ID}{$gene_name} }, $ncoord);
		    
		    $found{$gene_name}++;
		}
		# Gene does NOT exist -> use coordinate
	    }elsif($gene eq " ") {
		
		$gene_name = "UNK";
	
		$ncoord=join("-",$coord, $mut);
		if ($freq<75) {
		    $ncoord=join("",$ncoord,$freq);
		}
		
		push( @{ $rows{$ID}{$gene_name} }, $ncoord);
		
		$found{$gene_name}++;
	    }
	}
    }
}
		



@setNames = sort keys %found;

print join ("\t", 'Name', @setNames), "\n";

foreach $rowName (sort keys %rows) {
    
    
    foreach $l (@setNames) {
	
	if (defined $rows{$rowName}{$l}) {
	    
#	    $val=join("+", @{$rows{$rowName}{$l}});
	    $val=join("", @{$rows{$rowName}{$l}});
	    
	    
	    push @data, $val;
		
	}else {
	    
	    push @data, "";
	}
	
	
    }
    print join("\t", $rowName, @data), "\n";
    @data=();
}






