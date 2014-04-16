#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Linker.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/InstIterator.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include <iostream>

static void sdt_emit_conv(const char* input, const char* output)
{
	llvm::LLVMContext& context = llvm::getGlobalContext();
	llvm::SMDiagnostic err;
	llvm::Module* conv_module = ParseIRFile("ext/conv.ll", err, context);
	llvm::Module* module = ParseIRFile(input, err, context);
	std::string errInfo;
	llvm::Linker::LinkModules(module, conv_module, llvm::Linker::DestroySource, &errInfo);
	llvm::Function* sdt_conv_init = module->getFunction("sdt_conv_init");
	llvm::Function* sdt_conv_for = module->getFunction("sdt_conv_for");
	llvm::Function* sdt_conv_close = module->getFunction("sdt_conv_close");
	int inst_no = 0;
	llvm::Value* sdt_conv_for_args[1];
	llvm::Module::iterator iit;
	for (iit = module->begin(); iit != module->end(); ++iit)
	{
		llvm::Function* func = &*iit;
		if (func != sdt_conv_init && func != sdt_conv_for && func != sdt_conv_close)
		{
			llvm::inst_iterator jit, je;
			for (jit = inst_begin(func), je = inst_end(func); jit != je; ++jit)
			{
				llvm::Instruction* inst = &*jit;
				if (!llvm::PHINode::classof(inst))
				{
					sdt_conv_for_args[0] = llvm::ConstantInt::get(llvm::IntegerType::get(context, 32), inst_no);
					llvm::CallInst* call_inst = llvm::CallInst::Create(sdt_conv_for, sdt_conv_for_args);
					call_inst->insertBefore(inst);
				}
				++inst_no;
			}
		}
	}
	llvm::Function* main_entry = module->getFunction("main");
	if (main_entry)
	{
		llvm::Value* sdt_conv_init_args[1];
		sdt_conv_init_args[0] = llvm::ConstantInt::get(llvm::IntegerType::get(context, 32), inst_no);
		llvm::CallInst* init_call_inst = llvm::CallInst::Create(sdt_conv_init, sdt_conv_init_args);
		init_call_inst->insertBefore(&*inst_begin(main_entry));
		llvm::CallInst* close_call_inst = llvm::CallInst::Create(sdt_conv_close);
		llvm::inst_iterator it, ie;
		llvm::Instruction* return_inst;
		for (it = inst_begin(main_entry), ie = inst_end(main_entry); it != ie; ++it)
		{
			return_inst = &*it;
			if (llvm::ReturnInst::classof(return_inst))
				close_call_inst->clone()->insertBefore(return_inst);
		}
		if (return_inst && !llvm::ReturnInst::classof(return_inst))
			close_call_inst->insertAfter(return_inst);
	}
	llvm::tool_output_file out(output, errInfo, llvm::sys::fs::F_RW);
	llvm::WriteBitcodeToFile(module, out.os());
	out.os().close();
	out.keep();
}

static void sdt_vacuum(const char* input, const char* output)
{
	unsigned int sdt_conv_size;
	FILE* conv = fopen("/tmp/sdt.out", "r");
	fscanf(conv, "%u", &sdt_conv_size);
	unsigned int* sdt_conv_c = (unsigned int*)calloc(sdt_conv_size, sizeof(unsigned int));
	int i;
	for (i = 0; i < sdt_conv_size; i++)
		fscanf(conv, "%u", sdt_conv_c + i);
	fclose(conv);
	llvm::LLVMContext& context = llvm::getGlobalContext();
	llvm::SMDiagnostic err;
	llvm::Module* module = ParseIRFile(input, err, context);
	for (;;)
	{
		int inst_no = 0;
		llvm::Module::iterator iit;
		for (iit = module->begin(); iit != module->end(); ++iit)
		{
			llvm::Function* func = &*iit;
			llvm::inst_iterator jit, je;
			int remove_one = 0;
			for (jit = inst_begin(func), je = inst_end(func); jit != je; ++jit)
			{
				llvm::Instruction* inst = &*jit;
				if (!llvm::PHINode::classof(inst) && !inst->isTerminator())
					if (sdt_conv_c[inst_no] == 0)
					{
						llvm::BasicBlock::iterator ii(inst);
						switch (inst->getType()->getTypeID())
						{
							case llvm::Type::IntegerTyID:
							case llvm::Type::HalfTyID:
							case llvm::Type::FloatTyID:
							case llvm::Type::DoubleTyID:
							case llvm::Type::X86_FP80TyID:
							case llvm::Type::FP128TyID:
							case llvm::Type::PPC_FP128TyID:
							case llvm::Type::PointerTyID:
							case llvm::Type::StructTyID:
							case llvm::Type::ArrayTyID:
							case llvm::Type::VectorTyID:
								llvm::ReplaceInstWithValue(inst->getParent()->getInstList(), ii, llvm::Constant::getNullValue(inst->getType()));
								break;
							default:
								inst->eraseFromParent();
						}
						memmove(sdt_conv_c + inst_no, sdt_conv_c + inst_no + 1, sizeof(unsigned int) * (sdt_conv_size - inst_no - 1));
						--sdt_conv_size;
						remove_one = 1;
						break;
					}
				++inst_no;
			}
			if (remove_one)
				break;
		}
		if (inst_no == sdt_conv_size)
			break;
	}
	std::string errInfo;
	llvm::tool_output_file out(output, errInfo, llvm::sys::fs::F_RW);
	llvm::WriteBitcodeToFile(module, out.os());
	out.os().close();
	out.keep();
}

int main(int argc, char** argv)
{
	if (argv[1][0] == 'c')
		sdt_emit_conv(argv[2], argv[3]);
	else if (argv[1][0] == 'v')
		sdt_vacuum(argv[2], argv[3]);
	return 0;
}
