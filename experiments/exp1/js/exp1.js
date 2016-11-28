// XTMEM 1 -- Replication of XT 2007a
// Overview: 
//      (1) Helper
//      (2) Parameters and Stimulus Setup 
//      (3) Control Flow

// TO DO: 
// get pics
// add q and a at end
// add white screen in between trials


// ---------------- 1. HELPER ------------------

/*Shows slides. We're using jQuery here the $ is the jQuery selector function, 
which takes as input either a DOM element or a CSS selector string. */
function showSlide(id) {

  $(".slide").hide();  //Hide all slides
  $("#"+id).show(); //Show just the slide we want to show
}

/**
*  from
*  http://stackoverflow.com/questions/2450954/how-to-randomize-a-javascript-array
* Randomize array element order in-place.
* Using Fisher-Yates shuffle algorithm.
*/
function shuffle(array) {
    for (var i = array.length - 1; i > 0; i--) {
        var j = Math.floor(Math.random() * (i + 1));
        var temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
    return array;
}

/* loads all of the images into the cache so they don't need to be individually
 * loaded at time of presentation. Ensures that experiment time happens as intended
 */
$.fn.preload = function() {
  this.each(function(){
        $('<img/>')[0].src = this;
    });
};

// ---------------- 2. PARAMETER SETUP ------------------
var total_trials = 12;

// -- Words--
var words = shuffle(["wug", "rab", "fep", "rif", "mep", "lim", "tob", "dit", "tev", "sib", "tur", "zom"])

// -- Pics -
var test_pics = ["c1_sub1", "c1_sub2", "c1_bas1", "c1_bas2", "c1_sup1", "c1_sup2", "c1_sup3", "c1_sup4",
                 "c2_sub1", "c2_sub2", "c2_bas1", "c2_bas2", "c2_sup1", "c2_sup2", "c2_sup3", "c2_sup4",
                 "c3_sub1", "c3_sub2", "c3_bas1", "c3_bas2", "c3_sup1", "c3_sup2", "c3_sup3", "c3_sup4"]

var train_one_pics = shuffle([["c1_sub3"],
                              ["c2_sub3"],
                              ["c3_sub3"]])

var train_sub_pics = shuffle([["c1_sub3", "c1_sub4", "c1_sub5"], 
                              ["c2_sub3", "c2_sub4", "c2_sub5"], 
                              ["c3_sub3", "c3_sub4", "c3_sub5"]])

var train_bas_pics = shuffle([["c1_sub3", "c1_bas3", "c1_bas4"], 
                              ["c2_sub3", "c2_bas3", "c2_bas4"],  
                              ["c3_sub3", "c3_bas3", "c3_bas4"]])

var train_sup_pics = shuffle([["c1_sub3", "c1_sup5", "c1_sup6"], 
                              ["c2_sub3", "c2_sup5", "c2_sup6"],  
                              ["c3_sub3", "c3_sup5", "c3_sup6"]])


// shuffle block order with constraint that one or sub appears first
var first_blocks = shuffle(["one", "sub"])
var blocks = ["bas", "sup"]
blocks.push(first_blocks[1])
blocks = shuffle(blocks)
blocks.unshift(first_blocks[0])

// PRE-LOAD IMAGES
var all_pics = [].concat.apply([], [train_one_pics, train_sub_pics, train_bas_pics, train_sup_pics, test_pics])
all_pics = [].concat.apply([], all_pics)

var images = []
for (i=0;i<54;i++) {
    images[i] = new Image()
    images[i].src = "images/" + all_pics[i] + ".jpg"
} 


// ---------------- 3. CONTROL FLOW ------------------

// Globalsvariables
var selected = []
var current_trial = 1
var current_trial_in_block = 0
var current_train_pics = []

// START experiment
showSlide("instructions");

// MAIN EXPERIMENT
var experiment = {

    /*start*/
    start: function() {  
        // Allow experiment to start if it's a turk worker OR if it's a test run
        if (window.self == window.top | turk.workerId.length > 0) {
              showSlide("instructions2");
        }     
    },

    /*test*/
    test: function() {  

        current_train_pics = shuffle(eval("train_" + blocks[0] + "_pics[" + current_trial_in_block + "]"))

        if (current_train_pics.length == 1) {
          var questionprompt_html = '<p style="font-size:18px"> <b> Here is a ' + words[current_trial-1] + '. Can you give Mr. Frog all the other ' + words[current_trial-1] + 's? </b></p>'
        } else { 
          var questionprompt_html = '<p style="font-size:18px"> <b> Here are three ' + words[current_trial-1] + 's. Can you give Mr. Frog all the other ' + words[current_trial-1] + 's? </b></p>'
        }
        $("#question").html(questionprompt_html) 

  
        // build train table of images
        train_pics_html = '<table align="center"><tr>'
        for (i=0;i<current_train_pics.length;i++){
          train_pics_html += '<td align="center">'
          train_pics_html += '<img src ="images/' + current_train_pics[i] + '.jpg"' 
          train_pics_html += 'alt="Stanford University" width="95"></td>'
        }

        train_pics_html += '</tr></table>'
        $("#trainPics").html(train_pics_html) 

        // build test table of images
        test_pics = shuffle(test_pics)
        test_pics_html = '<table align="center">'
        test_pics_html += '<tr><td colspan="5"><p style="font-size:18px;text-align:left; font-style:italic" > To give a ' + words[current_trial-1] + ', click on it below. When you have given all the ' + words[current_trial-1] + 's, click the Next button. </p></td></tr><tr>'
        for (i=0;i<=24-1;i++){
          test_pics_html += '<td align="center" > <input src="images/' + test_pics[i] + '.jpg" type="image"'
          test_pics_html += "onclick='experiment.highlight(this,\""+ test_pics[i] +"\")' width='95' style='border:10px solid white'/>"

          if((i+1)%6 == 0) {
            test_pics_html += "</tr><tr>"
          }
        }
        test_pics_html += '</tr></table>'
        $("#testPics").html(test_pics_html)

        $("#counter").html(current_trial + ' / ' + total_trials)  

        showSlide('grid')
    },

    highlight: function(el, given_obj) {
      
      if (el.style.border == "10px solid red"){
        el.style.border = "10px solid white"

        // remove from "selected" array if participant unselects pic
        var unselected_index = selected.indexOf(given_obj)
        if (unselected_index > -1) {
          selected.splice(unselected_index, 1);
        }

      } else {
        el.style.border = "10px solid red"
        selected.push(given_obj)
      }
    },

    next: function() {
      if (selected.length > 0){
        
          // save data
          eval('experiment.selected_T' + current_trial + ' = ' + "'" + selected + "'" )
          eval('experiment.trainBlock_T' + current_trial + ' = ' + "'" + blocks[0] + "'" )
          eval('experiment.category_T' + current_trial + ' = ' + "'" + current_train_pics[0].split("_")[0] + "'" )
         
         if(current_trial_in_block == 2) {
            blocks.shift()
            current_trial_in_block = 0
          } else {
            current_trial_in_block++ //increment trial in block
          }

        current_trial++ // increment trial
        selected = [] // clear global selected variable
        $("#message").html(""); // clear message text
        
        if (current_trial > total_trials) {
            experiment.end()
        } else {
            setTimeout(experiment.blank,1);
            //experiment.test()
        }

      } else {
         $("#message").html('<font color="red">Please select all the other ' + words[current_trial-1] + 's!</font>');
      }
    }, 

    blank: function(){
        //show blank slide
      showSlide("blankSlide");
      // next trial
      setTimeout(experiment.test, 500);  
    },

    /*end*/
    end: function() {

      // // store values from q and a 
      // experiment.subj_data = {
      //     language : $("#language").val(),
      //     enjoyment : $("#enjoyment").val(),
      //     asses : $('input[name="assess"]:checked').val(),
      //     age : $("#age").val(),
      //     gender : $("#gender").val(),
      //     education : $("#education").val(),
      //     comments : $("#comments").val(),
      //   };

      // show finished slide
      showSlide("finished"); 
      // Submit to turk
      setTimeout(function() {   
        turk.submit(experiment)
          }, 1500);
    }
}
