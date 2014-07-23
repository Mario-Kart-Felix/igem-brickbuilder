/*-----------------------------------------------
  ------- Sequences should not have these -------
  -----------------------------------------------*/

var isCompatible = function(sqnc) {
	if(sqnc.search("GAATTC") !== -1) {
		return false;
	} else if(sqnc.search("ACTAGT") !== -1) {
		return false;
	} else if(sqnc.search("GCTAGC") !== -1) {
		return false;
	} else if(sqnc.search("CTGCAG") !== -1) {
		return false;
	} else if(sqnc.search("GCGGCCGC") !== -1) {
		return false;
	} else {
		return true;
	}
};

// Sites that are not recommended inside the sequence
var warningSites = function(sqnc) {
	var warning = [];
	if(sqnc.search("CAGCTG") !== -1) {
		warning.push("CAGCTG");
	} else if(sqnc.search("CTCGAG") !== -1) {
		warning.push("CTCGAG");
	} else if(sqnc.search("CCTAGG") !== -1) {
		warning.push("CCTAGG");
	} else if(sqnc.search("TCTAGA") !== -1) {
		warning.push("TCTAGA");
	} else if(sqnc.search("GCTCTTC") !== -1) {
		warning.push("GCTCTTC");
	} else if(sqnc.search("GAAGAGC") !== -1) {
		warning.push("GAAGAGC");
	}

	//Alerting the user
	if(warning.length !== 0) {
		var mess = "WARNING: the sequence has the following restricted sites...\n" + warning.join("\n");
		console.log(mess);
	}
};

/*------------------------------------------------
  ------- Calculating Melting Temperatures -------
  ------------------------------------------------*/

var calculateMeltingTemperature = function(sqnc) {
	var R = 1.987;
	var H = 0;
	var S = 0;
	var fractionOfGCbp = 0;

	for(var i=0; i<sqnc.length-1; i++) {
		var bp = sqnc.substring(i,i+2);
		if(bp === "GC"){
			fractionOfGCbp++;
		}
		var nnValues = findValues(bp);
		H+=nnValues[0];
		S+=nnValues[1];
	}

	fractionOfGCbp = fractionOfGCbp/sqnc.length;
	var startingValues = initValues(sqnc.charAt(0));
	var endingValues = initValues(sqnc.charAt(sqnc.length-1));
	H = H + startingValues[0] + endingValues[0];
	S = S + startingValues[1] + endingValues[1];
	
	// Entropy correction due to  salt dependence
	S = S + 0.368 * (sqnc.length - 1) * Math.log(0.05); // Default [Na+] = 50 microMolar


	var meltingTemp = ((1000 * H) / (S + (R * Math.log(250*Math.pow(10,-9) / 2)))) - 273.15; // Default [oligo] = 0.25 microMolar
	// console.log(meltingTemp);
	return meltingTemp;
};

// Finds enthalpy and entropy values for given nearest neighbour nucleotides
var findValues = function(neighbor) {
	var nnThermo = [0,0];

	switch(neighbor){
		case "AA":
		case "TT":
			nnThermo = [-7.9, -22.2];
			break;
		case "AT":
			nnThermo = [-7.2, -20.4];
			break;
		case "TA":
			nnThermo = [-7.2, -21.3];
			break;
		case "CA":
		case "TG":
			nnThermo = [-8.5, -22.7];
			break;
		case "GT":
		case "AC":
			nnThermo = [-8.4, -22.4];
			break;
		case "CT":
		case "AG":
			nnThermo = [-7.8, -21];
			break;
		case "GA":
		case "TC":
			nnThermo = [-8.2, -22.2];
			break;
		case "CG":
			nnThermo = [-10.6, -27.2];
			break;
		case "GC":
			nnThermo = [-9.8, -24.4];
			break;
		case "GG":
		case "CC":
			nnThermo = [-8, -19.9];
			break;
		default:
	}
	return nnThermo;
};

// Determines initial values for enthalpy and entropy for given sequence
var initValues = function(c) {
	var result = [];
	switch(c) {
		case "A":
		case "T":
			result = [2.3, 4.1];
			break;
		case "G":
		case "C":
			result = [0.1, -2.8];
			break;
		default:
	}
	return result;
};


/*-------------------------------------------
  ------- Complimentary sequence code -------
  -------------------------------------------*/
var reverseNts = function(sqnc) {
	sqnc = sqnc.replace(/A/g,"X");
	sqnc = sqnc.replace(/T/g,"A");
	sqnc = sqnc.replace(/X/g,"T");
	sqnc = sqnc.replace(/G/g,"X");
	sqnc = sqnc.replace(/C/g,"G");
	sqnc = sqnc.replace(/X/g,"C");
	sqnc = sqnc.split("").reverse().join("");
	return sqnc;
};

/*-----------------------------
  ------- Fp's and Rp's -------
  -----------------------------*/

var generatePrimers = function(sqnc) {
	var pre = "GAATTCGCGGCCGCACTAGT";
	var suf = "CTGCAGCGGCCGCGCTAGC";
	
	var bank = [sqnc, reverseNts(sqnc)];
	

	//Calculating for Fp
	var fp = bank[0].substr(0,10);
	for(var i=10; i<bank[0].length; i++){
		var meltTemp = calculateMeltingTemperature(fp);
		if(meltTemp >= 65){
			console.log("Primers with annealing temperatures in this range cannot be made. Please input a larger temperature range.");
			break;
		} else {
			if(meltTemp > 55 && meltTemp < 65){
				break;
			} else {
				fp = fp.concat(bank[0].charAt(i));
			}
		}
	}
	if(calculateMeltingTemperature(fp) <= 55){
		console.log("Primers with annealing temperatures in this range cannot be made. Please input a larger temperature range.");
	}
	
	// Adding prefix
	fp = pre + fp;

	console.log("Forward Primer: 5'-" + fp + "-3'");
	
	//Calculating for Rp
	var rp = bank[1].substr(0,10);
	for(var i=10; i<bank[1].length; i++){
		var meltTemp = calculateMeltingTemperature(rp);
		if(meltTemp >= 65){
			console.log("Primers with annealing temperatures in this range cannot be made. Please input a larger temperature range.");
			break;
		} else {
			if(meltTemp > 55 && meltTemp < 65){
				break;
			} else {
				rp = rp.concat(bank[1].charAt(i));
			}
		}
	}
	if(calculateMeltingTemperature(rp) <= 55){
		console.log("Primers with annealing temperatures in this range cannot be made. Please input a larger temperature range.");
	}
	
	// Adding suffix
	rp = suf + rp;
	
	console.log("Reverse Primer: 5'-" + rp + "-3'");

	return [fp,rp];
};

/*---------------------
  ------- START -------
  ---------------------*/
var sequence = "cacttagacggcgaggacgtggcgatggcgcatgccgacgcgctagacgatttcgatctggacatgttgggggacggggattccccggggccgggatttaccccccacgactccgccccctacggcgctctggatatggccgacttcgagtttgagcagatgtttaccgatgcccttggaattgacgagtacggtggg";
sequence = sequence.toUpperCase();
if(isCompatible(sequence)) {
	warningSites(sequence);
	var primers = generatePrimers(sequence);
	window.confirm("Forward primer: " + primers[0] + "\nReverse primer: " + primers[1]);
	//console.log("Forward primer: " + primers[0]);
	//console.log("Reverse primer: " + primers[1]);
} else {
	alert("THIS SEQUENCE IS NOT COMPATIBLE WITH RFC12!")
};
