/*---------------------------------------
  ------- Check RFC compatibility -------
  ---------------------------------------*/

// Also checks RFC23
var isCompatible10 = function(sqnc) {
    if(sqnc.search("GAATTC") !== -1) {
        return false;
    } else if(sqnc.search("TCTAGA") !== -1) {
        return false;
    } else if(sqnc.search("ACTAGT") !== -1) {
        return false;
    } else if(sqnc.search("CTGCAG") !== -1) {
        return false;
    } else if(sqnc.search("GCGGCCGC") !== -1) {
        return false;
    } else {
        return true;
    }
};

var isCompatible12 = function(sqnc) {
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

var isCompatible21 = function(sqnc) {
    if(sqnc.search("GAATTC") !== -1) {
        return false;
    } else if(sqnc.search("AGATCT") !== -1) {
        return false;
    } else if(sqnc.search("GGATCC") !== -1) {
        return false;
    } else {
        return true;
    }
};

var isCompatible25 = function(sqnc) {
    if(sqnc.search("GAATTC") !== -1) {
        return false;
    } else if(sqnc.search("TCTAGA") !== -1) {
        return false;
    } else if(sqnc.search("ACTAGT") !== -1) {
        return false;
    } else if(sqnc.search("CTGCAG") !== -1) {
        return false;
    } else if(sqnc.search("GCGGCCGC") !== -1) {
        return false;
    } else if(sqnc.search("ACCGGT") !== -1){
        return false;
    } else if(sqnc.search("GCCGGC") !== -1){
        return false;
    } else {
        return true;
    }
};

/*------------------------------------
  ------- Counting Nucleotides -------
  ------------------------------------*/

var countNts = function(sqnc) {
    var nts = [0,0,0,0]; // ATGC in corresponding index
    for(var i=0; i<sqnc.length; i++){
        var c = sqnc.charAt(i);
        switch(c) {
            case "A":
                nts[0]++;
                break;
            case "T":
                nts[1]++;
                break;
            case "G":
                nts[2]++;
                break;
            case "C":
                nts[3]++;
                break;
            default:
                /*Do nothing*/
        }
    }
    return nts;
};

/*------------------------------------------------
  ------- Calculating Melting Temperatures -------
  ------------------------------------------------*/
var calcMeltTemp = function(sqnc) {
    var nts = countNts(sqnc);
    return (64.9 + (41 * (nts[2] + nts[3] - 16.4) / sqnc.length));
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
var findPrimers = function(sqnc, methodNum, isCoding){
    var primers10 = ["GAATTCGCGGCCGCTTCTAGAG","GAATTCGCGGCCGCTTCTAG","CTGCAGCGGCCGCTACTAGTA"];
    var primers12 = ["GAATTCGCGGCCGCACTAGT","","CTGCAGCGGCCGCGCTAGC"];
    var primers21 = ["GAATTCATGAGATCT","CTCGAGTTAGGATCC"];
    var primers23 = ["GAATTCGCGGCCGCTTCTAGA","CTGCAGCGGCCGCTACTAGT"];
    var primers25 = ["GAATTCGCGGCCGCTTCTAGATGGCCGGC","CTGCAGCGGCCGCTACTAGTATTAACCGGT"];
    var primers = ["",""];
    switch(methodNum){
        case "10" || "RFC10":
            if(!isCompatible10(sqnc)){
                console.log("Part is not compatible with RFC 10");
                break;
            } else {
                if(isCoding){
                    primers = getPrimer(sqnc,primers10,1);
                } else {
                    primers = getPrimer(sqnc,primers10,0);
                }
                break;
            }
        case "12" || "RFC12":
            if(!isCompatible12(sqnc)){
                console.log("Part is not compatible with RFC 12");
                break;
            } else {
                primers = getPrimer(sqnc,primers12,0);
                break;
            }
        case "21" || "RFC21":
            if(!isCompatible21(sqnc)){
                console.log("Part is not compatible with RFC 21");
                break;
            } else {
                primers = getPrimer(sqnc,primers21);
                break;
            }
        case "23" || "RFC23":
            if(!isCompatible10(sqnc)){
                console.log("Part is not compatible with RFC 23");
                break;
            } else {
                primers = getPrimer(sqnc,primers23);
                break;
            }
        case "25" || "RFC25":
            if(!isCompatible25(sqnc)){
                console.log("Part is not compatible with RFC 25");
                break;
            } else {
                primers = getPrimer(sqnc,primers25);
                break;
            }
        default:
            /*Do nothing*/
    }
    return primers;
};

var getPrimer = function(sqnc,frp,op) {
    var temp = [frp[op] + sqnc, frp[2] + reverseNts(sqnc)];

    //Calculating for Fp
    var fp = temp[0].substring(0,18);
    for(var i=18; i<temp[0].length; i++){
        var meltTemp = calcMeltTemp(fp)
        if(55 <= meltTemp && meltTemp <= 60){
            break;
        } else {
            fp = fp.concat(temp[0].charAt(i));
        }
    }

    //Calculating for Rp
    var rp = temp[1].substring(0,18);
    for(var i=18; i<temp[1].length; i++){
        var meltTemp = calcMeltTemp(rp)
        if(55 <= meltTemp && meltTemp <= 60){
            break;
        } else {
            rp = rp.concat(temp[1].charAt(i));
        }
    }
    return [fp, rp];
};

/*------------------
  ------- UI -------
  ------------------*/
var browserUI = function() {
    try{
        var part = prompt("Enter the name of your desired part (Case-sensitive):", "BBa_");
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://parts.igem.org/xml/part." + part, false);
        xhr.send();

        var xmlDoc = xhr.responseXML;
        var name = xmlDoc.getElementsByTagName("part_name")[0].childNodes[0].nodeValue;
    } catch (err) {
        alert("Your answer is invalid.");
    }
    var title = xmlDoc.getElementsByTagName("part_short_desc")[0].childNodes[0].nodeValue;
    var sequence = xmlDoc.getElementsByTagName("seq_data")[0].childNodes[0].nodeValue.toUpperCase().trim();
    var nts = countNts(sequence);
    var length = nts[0] + nts[1] + nts[2] + nts[3];
    var subDate = xmlDoc.getElementsByTagName("part_entered")[0].childNodes[0].nodeValue;
    var exp = "Experience: " + xmlDoc.getElementsByTagName("part_results")[0].childNodes[0].nodeValue;
    var RFC10 = isCompatible10(sequence);
    var RFC12 = isCompatible12(sequence);
    var RFC21 = isCompatible21(sequence);
    var RFC25 = isCompatible25(sequence);
    var isCoding = prompt("Is this part non-coding? (yes/no)");
    isCoding.toLowerCase();
    isCoding = (isCoding === 'yes') ? true : false;

    console.log("BioBrick: " + name);
    console.log("Title: " + title);
    console.log("Length: " + length + " bp");
    console.log("Submission Date: " + subDate);
    console.log("Experience: " + exp);
    console.log("Sequence: " + sequence);
    console.log("Compatible with RFC 10: " + RFC10);
    console.log("Compatible with RFC 12: " + RFC12);
    console.log("Compatible with RFC 21: " + RFC21);
    console.log("Compatible with RFC 23: " + RFC10);
    console.log("Compatible with RFC 25: " + RFC25);

    var answer = "";
    do{
        answer = prompt("Choose one of the following assembly standards:\nRFC 10\nRFC 12\nRFC 21\nRFC 23\nRFC 25");
        answer.toUpperCase();
        answer.trim();
        if(answer === "10" ||
           answer === "12" ||
           answer === "21" ||
           answer === "23" ||
           answer === "25" ||
           answer === "RFC10" ||
           answer === "RFC12" ||
           answer === "RFC21" ||
           answer === "RFC23" ||
           answer === "RFC25") {
            break;
        } else {
            answer = alert("Your answer is invalid. Please try again.");
        }
    } while (true);

    var primers = findPrimers(sequence,answer, isCoding);
    console.log("Forward primer: " + primers[0]);
    console.log("Reverse primer: " + primers[1]);
};

exports.countNts = countNts;
exports.reverseNts = reverseNts;
exports.findPrimers = findPrimers;
exports.getPrimer = getPrimer;
