class axi_driver extends uvm_driver #(axi_seq_item);
    `uvm_component_utils(axi_driver)

    virtual axi_if vif;
    
    function new(string name = "axi_driver" , uvm_component parent = null);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual axi_if)::get(this,"","vif",vif))
            `uvm_fatal("NOVIF","Driver: no virtual interface found in config_db")
    endfunction


    task run_phase(uvm_phase phase);
        // initialize all output to zero
        init_to_zero_all_output();        
        
        // Wait for reset to deassert
        @(posedge vif.clk);
        while(!vif.rst_n) @(posedge vif.clk);  
        `uvm_info("DRV", "Driver initialized, waiting for items", UVM_LOW)

        forever begin
            
            seq_item_port.get_next_item(req);
            if(req.op == AXI_WRITE)
                do_write(req);
            else
                do_read(req);
            seq_item_port.item_done();
        end
        
    endtask


    
    
    //task to write
    
    task do_write(axi_seq_item req);
        // AW Channel
        vif.awvalid <= 1;
        vif.awaddr <= req.awaddr;
        while(!vif.awready) @(posedge vif.clk);
        vif.awvalid <= 0;
        
        // W Channel
        vif.wvalid <= 1;
        vif.wdata  <= req.wdata;
        vif.wstrb  <= req.wstrb;
        @(posedge vif.clk);
        while(!vif.wready) @(posedge vif.clk);
        vif.wvalid <= 0;

        //B channel
        vif.bready <= 1;
        @(posedge vif.clk);
        while(!vif.bvalid) @(posedge vif.clk);
        req.bresp = vif.bresp;
        vif.bready <= 0;
    
    endtask : do_write
    

    //task to read 
    task do_read(axi_seq_item req);
        
        //AR channel
        vif.arvalid <= 1;
        vif.araddr <= req.araddr;
        @(posedge vif.clk);
        while(!vif.arready) @(posedge vif.clk);
        vif.arvalid <= 0;
        
        //R Channel
        vif.rready <= 1;
        @(posedge vif.clk);
        while(!vif.rvalid) @(posedge vif.clk);
        req.rdata = vif.rdata;
        req.rresp = vif.rresp;
        vif.rready<= 0;

    endtask: do_read
    
    
    
    
    task init_to_zero_all_output();
        
        vif.rready  <=  0;
        vif.awvalid <=  0;
        vif.awaddr  <= '0;
        vif.wvalid  <=  0;
        vif.wdata   <= '0;
        vif.wstrb   <= '0;
        vif.bready  <=  0;
        vif.arvalid <=  0;
        vif.araddr  <= '0;
    
    endtask

endclass