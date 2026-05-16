`ifndef AXI_SCOREBOARD_SV
`define AXI_SCOREBOARD_SV

class axi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_scoreboard)

  uvm_analysis_imp #(axi_seq_item, axi_scoreboard) item_export;
  bit [31:0] reg_file [4];

  function new(string name = "axi_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_export = new("item_export", this);
  endfunction
  
  function void write(axi_seq_item item);
    case (item.op)
      AXI_WRITE: begin
        if(is_valid_addr(item.awaddr)) begin
             for(int b = 0; b < 4; b++) begin
                 if(item.wstrb[b])
                     reg_file[item.awaddr[3:2]][b*8 +: 8] = item.wdata[b*8 +: 8];
             end
             if(item.bresp == 2'b00)
                 `uvm_info("SCB", $sformatf("PASS: addr=0x%0h data=0x%0h",
                     item.awaddr, item.wdata), UVM_LOW)
             else
                 `uvm_error("SCB", $sformatf("FAIL: valid addr got bresp=%0b",
                     item.bresp))
        end else begin                         
             if(item.bresp == 2'b10)
                 `uvm_info("SCB", $sformatf("PASS: invalid addr=0x%0h got SLVERR",
                     item.awaddr), UVM_LOW)
             else
                 `uvm_error("SCB", $sformatf("FAIL: invalid addr expected SLVERR got %0b",
                     item.bresp))
         end 
        end 
      AXI_READ: begin
        if(is_valid_addr(item.araddr)) begin
          if(item.rresp == 2'b00) begin

            if(item.rdata == reg_file[item.araddr[3:2]])
            `uvm_info("SCB", $sformatf("PASS: addr=0x%0h expected=0x%0h got=0x%0h",
                    item.araddr, reg_file[item.araddr[3:2]], item.rdata), UVM_LOW)
            else
              `uvm_error("SCB", $sformatf("FAIL: addr=0x%0h expected=0x%0h got=0x%0h",
              item.araddr, reg_file[item.araddr[3:2]], item.rdata))
          end else
            `uvm_error("SCB", $sformatf("FAIL: valid addr expected OKAY got %0b",item.rresp))

          
        end else begin
          if (item.rresp == 2'b10) 
            `uvm_info("SCB", $sformatf("PASS: invalid addr=0x%0h got SLVERR",
                     item.araddr), UVM_LOW)
          else 
          `uvm_error("SCB", $sformatf("FAIL: invalid addr expected SLVERR got %0b",
                     item.rresp))
        end  
      end
    endcase
        
  endfunction

  function bit is_valid_addr(logic [3:0] addr);
    return (addr[1:0] == 2'b00) && (addr[3:2] < 4);
  endfunction
endclass

`endif
