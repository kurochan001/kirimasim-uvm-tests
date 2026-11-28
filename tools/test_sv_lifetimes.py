"""Regression cases for the initialized-local lifetime guard."""

import unittest

import sv_lifetimes


class ProceduralLifetimes(unittest.TestCase):
    def names(self, source):
        return [x.name for x in sv_lifetimes.implicit_initializers(source)]

    def test_implicit_builtin_and_user_types_are_reported(self):
        for declaration in ('int value = 1;', 'packet value = new;',
                            'byte unsigned value[] = new[2];',
                            'uvm_queue#(int) value = new;',
                            'uvm_policy::recursion_state_e value = uvm_policy::NEVER;'):
            with self.subTest(declaration=declaration):
                self.assertEqual(self.names('initial begin ' + declaration + ' end'), ['value'])

    def test_explicit_lifetimes_are_allowed(self):
        self.assertEqual(self.names('''
initial begin
  automatic int each_entry = 1;
  static int once = 1;
  const automatic int limit = 7;
end
'''), [])

    def test_module_members_and_class_methods_are_outside_the_guard(self):
        self.assertEqual(self.names('''
module m;
  int global_value = 1;
  class item;
    int member_value = 1;
    function void operation(); int local_value = 1; endfunction
  endclass
  function automatic int helper(); int local_value = 1; return local_value; endfunction
  initial run_test();
endmodule
'''), [])

    def test_nested_blocks_and_forks_are_checked(self):
        self.assertEqual(self.names('''
initial begin : root
  fork : workers
    begin : child
      int value = 3;
    end : child
    begin
      for (int i=0; i<2; i++) begin
        int per_iteration = i;
      end
    end
  join
end : root
'''), ['value', 'per_iteration'])

    def test_comments_and_strings_do_not_change_the_scope(self):
        self.assertEqual(self.names(r'''
// initial begin int bogus = 1; end
initial begin
  /* end; initial begin int bogus = 1; */
  automatic string message = "end; initial begin int bogus = 1; \\";
  int actual = 2;
  $display("begin; fork; end; join");
end
'''), ['actual'])

    def test_assignments_and_calls_are_not_declarations(self):
        self.assertEqual(self.names('''
initial begin
  value = make();
  object.field = value;
  uvm_config_db#(int)::set(null, "scope", "field", value);
  if (value == 1) begin value++; end
  void'(object.call());
end
'''), [])

    def test_array_initializers_and_multiple_declarators(self):
        self.assertEqual(self.names('''
initial begin
  int values[] = '{1, 2, 3};
  int first, second = 7;
  automatic int matrix[2][2] = '{'{1, 2}, '{3, 4}};
end
'''), ['values', 'first'])

    def test_each_process_is_checked_after_event_and_delay_controls(self):
        self.assertEqual(self.names('''
initial #1 begin int first = 1; end
always_ff @(posedge clk) begin bit second = 0; end
always_comb begin int third = 2; end
initial begin int fourth = 4; end
'''), ['first', 'second', 'third', 'fourth'])

    def test_multiline_declaration_and_insertion_position(self):
        source = 'initial begin\n  const var packet#(int)\n    value = new;\nend\n'
        found = sv_lifetimes.implicit_initializers(source)
        self.assertEqual([(x.name, x.line) for x in found], [('value', 2)])
        self.assertTrue(source[found[0].offset:].startswith('packet'))
        fixed = source[:found[0].offset] + 'automatic ' + source[found[0].offset:]
        self.assertEqual(self.names(fixed), [])

    def test_anonymous_struct_and_packed_bounds(self):
        self.assertEqual(self.names('''
initial begin
  struct packed { int field; } aggregate = '{field: 1};
  logic signed [width-1:0] value = 0;
end
'''), ['aggregate', 'value'])

    def test_fork_join_variants_keep_the_enclosing_scope(self):
        for join in ('join', 'join_any', 'join_none'):
            with self.subTest(join=join):
                source = f'''
initial begin : root
  fork : workers
    begin int worker = 3; end
  {join} : workers
  begin int after_workers = 4; end
end : root
'''
                self.assertEqual(self.names(source), ['worker', 'after_workers'])

    def test_loop_header_and_uninitialized_locals_do_not_report(self):
        self.assertEqual(self.names('''
always_latch begin
  int uninitialized;
  for (int index = 0; index < 2; ++index) begin
    int per_iteration = index;
  end
end
initial run_test();
initial begin int later_process = 0; end
'''), ['per_iteration', 'later_process'])


if __name__ == '__main__':
    unittest.main()
