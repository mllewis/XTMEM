// XTMEM 1 -- Replication of XT 2007a
// Overview: 
//      (1) Helper
//      (2) Parameters and Stimulus Setup 
//      (3) Control Flow


// ---------------- 1. HELPER ------------------

/*Shows slides. We're using jQuery here the $ is the jQuery selector function, 
which takes as input either a DOM element or a CSS selector string. */
function showSlide(id) {

  $(".slide").hide();  //Hide all slides
  $("#"+id).show(); //Show just the slide we want to show
}

/*Get random integers. When called with no arguments, it returns either 0 or 1. 
When called with one argument, a, it returns a number in [0,a-1]. 
When called with two arguments, a and b, returns a random value in [a,b]. */

function random(a,b) {
  if (typeof b == "undefined") {
    a = a || 2;
    return Math.floor(Math.random()*a);
  } else {
    return Math.floor(Math.random()*(b-a+1)) + a;
  }
}

// returns selected elements and creates a new array with those elements (called 'foo')

function range(start, end)
{
    var foo = [];
    for (var i = start; i <= end; i++)
        foo.push(i);
    return foo;
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

function shuffleObjectArray(array) {
    for (var i = array.length - 1; i > 0; i--) {
        var j = Math.floor(Math.random() * (i + 1));
        var temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
    return array;
}


function mark(el) {
    el.style.border = "1px solid blue";
}

/*Randomly return an element from an array. Useful for condition randomization.*/
Array.prototype.random = function() {
  return this[random(this.length)];
};

/* loads all of the images into the cache so they don't need to be individually
 * loaded at time of presentation. Ensures that experiment time happens as intended
 */
$.fn.preload = function() {
  this.each(function(){
        $('<img/>')[0].src = this;
    });
};

// ---------------- 2. PARAMETER SETUP ------------------
var num_correct_in_block = 0;
var num_blocks = 2;
var num_trials_block = 48;
var num_trials = num_trials_block * num_blocks;

// -- Words--
var words = [ "tep", "rab", "fep", "dax", "mep", "bix", "tob", "dit", "wud", "sib", "tur", "zom"]

// -- Pics -
var train_pics = ["c1_sub1", "c1_sub2", "c1_bas1", "c1_bas2", "c1_sup1", "c1_sup2", "c1_sup3", "c1_sup4",
                  "c2_sub1", "c2_sub2", "c2_bas1", "c2_bas2", "c2_sup1", "c2_sup2", "c2_sup3", "c2_sup4",
                  "c3_sub1", "c3_sub2", "c3_bas1", "c3_bas2", "c3_sup1", "c3_sup2", "c3_sup3", "c3_sup4"]

var test_pics = [["c1_sub3", "", ""],
                 ["c2_sub3", "", ""],
                 ["c3_sub3", "", ""],
                 ["c1_sub3", "c1_sub4", "c1_sub5"], 
                 ["c2_sub3", "c2_sub4", "c2_sub5"], 
                 ["c3_sub3", "c3_sub4", "c3_sub5"],
                 ["c1_sub3", "c1_bas3", "c1_bas4"], 
                 ["c2_sub3", "c2_bas3", "c2_bas4"],  
                 ["c3_sub3", "c3_bas3", "c3_bas4"], 
                 ["c1_sub3", "c1_sup5", "c1_sup6"], 
                 ["c2_sub3", "c2_sup5", "c2_sup6"],  
                 ["c3_sub3", "c3_sup5", "c3_sup6"]]




// ---------------- 3. CONTROL FLOW ------------------

// START experiment
showSlide("instructions");

// MAIN EXPERIMENT
var experiment = {
  
    /*start*/
    start: function() {  
        // Allow experiment to start if it's a turk worker OR if it's a test run
        if (window.self == window.top | turk.workerId.length > 0) {
              showSlide("instructions2");
              alert("hey!")
        }     
    },

     /*train*/
    train: function() {  

    },

    /*test*/
    test: function() {  

    },
    
    /*end*/
    end: function() {

      // store values from q and a 
      experiment.subj_data = {
          language : $("#language").val(),
          enjoyment : $("#enjoyment").val(),
          asses : $('input[name="assess"]:checked').val(),
          age : $("#age").val(),
          gender : $("#gender").val(),
          education : $("#education").val(),
          comments : $("#comments").val(),
        };

      // show finished slide
      showSlide("finished"); 
      // Submit to turk
      setTimeout(function() {   
        turk.submit(experiment)
          }, 1500);
    }
}


