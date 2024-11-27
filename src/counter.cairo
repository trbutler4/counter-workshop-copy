#[starknet::interface]
trait ICounter<T> {
    fn get_counter(self: @T) -> u32;
    fn increase_counter(ref self: T);
    fn decrease_counter(ref self: T);
    fn reset_counter(ref self: T);
}


#[starknet::contract]
mod Counter {
    use super::ICounter;
    use openzeppelin_access::ownable::OwnableComponent;
    use starknet::ContractAddress;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    // Ownable Mixin
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl InternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        counter: u32,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CounterIncreased: CounterIncreased,
        CounterDecreased: CounterDecreased,
        #[flat]
        OwnableEvent: OwnableComponent::Event
    }

    #[derive(Drop, starknet::Event)]
    struct CounterIncreased {
        counter: u32,
    }

    #[derive(Drop, starknet::Event)]
    struct CounterDecreased {
        counter: u32,
    }

    pub mod Errors {
        pub const NEGATIVE_COUNTER: felt252 = 'Counter can\'t be negative';
    }

    #[constructor]
    fn constructor(ref self: ContractState, init_value: u32, owner: ContractAddress) {
        self.counter.write(init_value);
        // Set the initial owner of the contract
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl CounterImpl of ICounter<ContractState> {
        fn get_counter(self: @ContractState) -> u32 {
            self.counter.read()
        }

        fn increase_counter(ref self: ContractState) {
            let old_counter = self.counter.read();
            let new_counter = old_counter + 1;
            self.counter.write(new_counter);
            self.emit(CounterIncreased { counter: new_counter });
        }

        fn decrease_counter(ref self: ContractState) {
            let old_counter = self.counter.read();
            assert(old_counter > 0, Errors::NEGATIVE_COUNTER);
            let new_counter = old_counter - 1;
            self.counter.write(new_counter);
            self.emit(CounterDecreased { counter: new_counter });
        }

        fn reset_counter(ref self: ContractState) {
            self.ownable.assert_only_owner();
            self.counter.write(0);
        }
    }
}
