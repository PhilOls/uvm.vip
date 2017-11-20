//
//------------------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   Copyright 2007-2011 Cadence Design Systems, Inc. 
//   Copyright 2010-2011 Synopsys, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Title: Comparators
//
// The following classes define comparators for objects and built-in types.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// CLASS: base_in_order_comparator #(T,comp_type,convert,pair_type)
//
// Compares two streams of data objects of the type parameter, T.
// These transactions may either be classes or built-in types. To be
// successfully compared, the two streams of data must be in the same order.
// Apart from that, there are no assumptions made about the relative timing of
// the two streams of data.
//
// Type parameters
//
//   T       - Specifies the type of transactions to be compared.
//
//   comp_type - A policy class to compare the two
//               transaction streams. It must provide the static method
//               "function bit comp(T a, T b)" which returns ~TRUE~
//               if ~a~ and ~b~ are the same.
//
//   convert - A policy class to convert the transactions being compared
//             to a string. It must provide the static method
//             "function string convert2string(T a)".
//
//  pair_type - A policy class to allow pairs of transactions to be handled as
//              a single <uvm_object> type.
//
// Built in types (such as ints, bits, logic, and structs) can be compared using
// the default values for comp_type, convert, and pair_type. For convenience,
// you can use the subtype, <base_in_order_built_in_comparator #(T)>
// for built-in types.
//
// When T is a <uvm_object>, you can use the convenience subtype
// <base_in_order_class_comparator #(T)>.
//
// Comparisons are commutative, meaning it does not matter which data stream is
// connected to which export, expected_export or actual_export.
//
// Comparisons are done in order and as soon as a transaction is received from
// both streams. Internal fifos are used to buffer incoming transactions on one
// stream until a transaction to compare arrives on the other stream.
//
//------------------------------------------------------------------------------

class base_in_order_comparator
  #( type T = int ,
     type comp_type = uvm_built_in_comp #( T ) ,
     type convert = uvm_built_in_converter #( T ) , 
     type pair_type = uvm_built_in_pair #( T ) )
    extends uvm_component;

  typedef base_in_order_comparator #(T,comp_type,convert,pair_type) this_type;
  `uvm_component_param_utils(this_type)

  const static string type_name = 
    "base_in_order_comparator #(T,comp_type,convert,pair_type)";

  // Port: expected_export
  //
  // The export to which one stream of data is written. The port must be
  // connected to an analysis port that will provide such data. 

  uvm_analysis_export #(T) expected_export;


  // Port: actual_export
  //
  // The export to which the other stream of data is written. The port must be
  // connected to an analysis port that will provide such data. 

  uvm_analysis_export #(T) actual_export;


  // Port: pair_ap
  //
  // The comparator sends out pairs of transactions across this analysis port.
  // Both matched and unmatched pairs are published via a pair_type objects.
  // Any connected analysis export(s) will receive these transaction pairs.

  uvm_analysis_port   #(pair_type) pair_ap;
  
  uvm_tlm_analysis_fifo #(T) m_expected_fifo;
  uvm_tlm_analysis_fifo #(T) m_actual_fifo;

  int m_matches, m_mismatches;

  int m_expected_fifo_used;
  int m_actual_fifo_used;

  function new(string name, uvm_component parent);

    super.new(name, parent);

    expected_export = new("expected_export", this);
    actual_export  = new("actual_export", this);
    pair_ap       = new("pair_ap", this);

    m_expected_fifo = new("expected", this);
    m_actual_fifo  = new("actual", this);
    m_matches = 0;
    m_mismatches = 0;

  endfunction
  
  virtual function string get_type_name();
    return type_name;
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    expected_export.connect(m_expected_fifo.analysis_export);
    actual_export.connect(m_actual_fifo.analysis_export);
  endfunction


  // Task- run_phase
  //
  // Internal method.
  //
  // Takes pairs of expected and actual transactions and compares them.
  // Status information is updated according to the results of the comparison.
  // Each pair is published to the pair_ap analysis port.

  virtual task run_phase(uvm_phase phase);
 
    pair_type pair;
    T b;
    T a;
  
    string s;
    bit stop_on_mismatch = 1;
    super.run_phase(phase); 
    forever begin
      
      m_expected_fifo.get(b);
      m_actual_fifo.get(a);
      
      if(!comp_type::comp(b, a)) begin

        $sformat(s, " Matches so far: %0d. Mismatches so far: %0d.  Remaining items in expected fifo: %0d, actual fifo: %0d / %s differs from %s",
          m_matches,
          m_mismatches,
          m_expected_fifo.used(),
          m_actual_fifo.used(),
          convert::convert2string(a),
          convert::convert2string(b));

        if (uvm_config_db#(bit)::get(uvm_root::get(), "uvm_test_top", "stop_on_mismatch", stop_on_mismatch)) begin
          if (stop_on_mismatch)
            `uvm_fatal("Comparator Mismatch", s)
          else
            `uvm_error("Comparator Mismatch", s)
        end
        else
          `uvm_error("Comparator Mismatch", s)

        m_mismatches++;

      end
      else begin
        s = convert::convert2string(b);
        `uvm_info("Comparator Match", $sformatf("%s vs %s \n%s", a.get_name(), b.get_name(), s), UVM_LOW)
        m_matches++;
      end

      // we make the assumption here that a transaction "sent for
      // analysis" is safe from being edited by another process.
      // Hence, it is safe not to clone a and b.
      
      pair = new("actual/expected");
      pair.first = a;
      pair.second = b;
      pair_ap.write(pair);
    end
  
  endtask

  function void extract_phase(uvm_phase phase);
     super.extract_phase(phase);
     m_expected_fifo_used = m_expected_fifo.used();
     m_actual_fifo_used = m_actual_fifo.used();
  endfunction:extract_phase

  function void check_phase(uvm_phase phase);
     super.check_phase(phase);
  endfunction:check_phase

  // Function: flush
  //
  // This method sets m_matches and m_mismatches back to zero. The
  // <uvm_tlm_fifo::flush> takes care of flushing the FIFOs.

  virtual function void flush();
    `uvm_fatal(get_full_name(), "Not yet supported.")
    m_matches = 0;
    m_mismatches = 0;
    m_expected_fifo.flush();
    m_actual_fifo.flush();
  endfunction
  
endclass


//------------------------------------------------------------------------------
//
// CLASS: base_in_order_built_in_comparator #(T)
//
// This class uses the uvm_built_in_* comparison, converter, and pair classes.
// Use this class for built-in types (int, bit, string, etc.)
//
//------------------------------------------------------------------------------

class base_in_order_built_in_comparator #(type T=int)
  extends base_in_order_comparator #(T);

  typedef base_in_order_built_in_comparator #(T) this_type;
  `uvm_component_param_utils(this_type)

  const static string type_name = "base_in_order_built_in_comparator #(T)";

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function string get_type_name ();
    return type_name;
  endfunction

endclass


//------------------------------------------------------------------------------
//
// CLASS: base_in_order_class_comparator #(T)
//
// This class uses the uvm_class_* comparison, converter, and pair classes.
// Use this class for comparing user-defined objects of type T, which must
// provide compare() and convert2string() method.
//
//------------------------------------------------------------------------------

class base_in_order_class_comparator #( type T = int )
  extends base_in_order_comparator #( T ,
                                     uvm_class_comp #( T ) , 
                                     uvm_class_converter #( T ) , 
                                     uvm_class_pair #( T, T ) );

  typedef base_in_order_class_comparator #(T) this_type;
  `uvm_component_param_utils(this_type)

  const static string type_name = "base_in_order_class_comparator #(T)";

  function new( string name  , uvm_component parent);
    super.new( name, parent );
  endfunction
  
  virtual function string get_type_name ();
    return type_name;
  endfunction

endclass
